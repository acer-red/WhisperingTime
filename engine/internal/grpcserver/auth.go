package grpcserver

import (
	"context"
	"errors"
	"fmt"
	"net"
	"os"
	"strings"
	"time"

	"github.com/acer-red/whisperingtime/engine/service/cache"
	"github.com/acer-red/whisperingtime/engine/service/modb"
	"github.com/acer-red/whisperingtime/engine/util"
	"github.com/golang-jwt/jwt/v5"
	"github.com/redis/go-redis/v9"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type ctxKey string

const (
	ctxUOIDKey ctxKey = "uoid"
	ctxUID     ctxKey = "uid"
)

// / 在redis里验证cookie是否合法
func validateCookie(ctx context.Context, cookieRowValue string) (string, error) {

	if !strings.HasPrefix(cookieRowValue, "jwt=") {
		log.Error("invalid cookie")
		return "", errors.New("invalid token")
	}
	cookieVal := strings.TrimPrefix(cookieRowValue, "jwt=")
	claims := &util.JWTClaims{}
	cookie, err := jwt.ParseWithClaims(cookieVal, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(os.Getenv(util.JwtEnvSecretKey)), nil
	})
	if err != nil {
		log.Errorf("%v", err)
		return "", err
	}
	if !cookie.Valid {
		log.Error("invalid cookie")
		return "", errors.New("invalid token")
	}
	log.Debug3f("需要查询的uid %s", claims.UserID)
	rdb := cache.Client()
	if rdb == nil {
		return "", errors.New("redis not initialized")
	}

	ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	val, err := rdb.Get(ctx, claims.GetKeyName()).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return "", errors.New("cookie not found")
		}
		return "", fmt.Errorf("redis get failed: %w", err)
	}
	if val == "" {
		return "", errors.New("cookie empty")
	}
	// write uid
	return claims.UserID, nil
}

func withAuth(ctx context.Context) (context.Context, error) {
	log.Debug3f("启动验证")
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		log.Error(errors.New("missing metadata"))
		return ctx, status.Error(codes.Unauthenticated, "missing metadata")
	}
	vals := md.Get("authorization")
	if len(vals) == 0 {
		return ctx, status.Error(codes.Unauthenticated, "missing cookie")
	}
	cookie := strings.TrimSpace(vals[0])
	if cookie == "" {
		return ctx, status.Error(codes.Unauthenticated, "missing cookie")
	}

	uid, err := validateCookie(ctx, cookie)
	if err != nil {
		return ctx, status.Error(codes.Unauthenticated, err.Error())
	}

	uoid, err := modb.GetUOIDFromUID(uid)
	if err != nil {

		return ctx, status.Error(codes.Unauthenticated, err.Error())
	}

	ctx = context.WithValue(ctx, ctxUOIDKey, uoid)
	ctx = context.WithValue(ctx, ctxUID, uid)
	log.Debug3f("验证完成 uid=%s,", uid)

	return ctx, nil
}

func unaryAuthInterceptor(
	ctx context.Context,
	req interface{},
	info *grpc.UnaryServerInfo,
	handler grpc.UnaryHandler,
) (interface{}, error) {
	// 在一元 RPC 入口做统一认证：从 metadata 取 cookie、校验、将认证上下文传入业务 handler。
	ctx, err := withAuth(ctx)
	if err != nil {
		return nil, err
	}
	return handler(ctx, req)
}

func streamAuthInterceptor(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
	// 在流式 RPC 入口做统一认证，并用 wrappedStream 注入带认证信息的 context。
	ctx, err := withAuth(ss.Context())
	if err != nil {
		return err
	}
	wrapped := &wrappedStream{ServerStream: ss, ctx: ctx}
	return handler(srv, wrapped)
}

type wrappedStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (w *wrappedStream) Context() context.Context { return w.ctx }

// / 重要函数
func getUID(ctx context.Context) string {
	if v := ctx.Value(ctxUID); v != nil {
		if s, ok := v.(string); ok {
			return s
		}
	}
	return ""
}

func getUOID(ctx context.Context) primitive.ObjectID {
	if v := ctx.Value(ctxUOIDKey); v != nil {
		if id, ok := v.(primitive.ObjectID); ok {
			return id
		}
	}
	return primitive.NilObjectID
}

// AddrHelper extracts host from configured address for logging.
func AddrHelper(address string, port int) string {
	host := address
	if ip := net.ParseIP(address); ip != nil {
		host = ip.String()
	}
	return net.JoinHostPort(host, fmt.Sprintf("%d", port))
}
