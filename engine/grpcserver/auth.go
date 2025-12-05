package grpcserver

import (
	"context"
	"encoding/base64"
	"errors"
	"fmt"
	"net"
	"strings"

	log "github.com/tengfei-xy/go-log"
	"github.com/tengfei-xy/whisperingtime/engine/modb"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

type ctxKey string

const (
	ctxUIDKey  ctxKey = "uid"
	ctxUOIDKey ctxKey = "uoid"
)

func parseBasicAuth(md metadata.MD) (string, error) {
	vals := md.Get("authorization")
	if len(vals) == 0 {
		return "", errors.New("missing authorization")
	}
	auth := vals[0]
	if !strings.HasPrefix(strings.ToLower(auth), "basic ") {
		return "", errors.New("authorization not basic")
	}
	raw := strings.TrimSpace(auth[len("basic "):])
	decoded, err := base64.StdEncoding.DecodeString(raw)
	if err != nil {
		return "", err
	}
	parts := strings.SplitN(string(decoded), ":", 2)
	if len(parts) == 0 || parts[0] == "" {
		return "", errors.New("invalid basic payload")
	}
	return parts[0], nil
}

func withAuth(ctx context.Context) (context.Context, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return ctx, status.Error(codes.Unauthenticated, "missing metadata")
	}
	uid, err := parseBasicAuth(md)
	if err != nil {
		return ctx, status.Error(codes.Unauthenticated, err.Error())
	}
	uoid, err := modb.EnsureUser(uid)
	if err != nil {
		log.Error(err)
		return ctx, status.Error(codes.Internal, "user lookup failed")
	}
	ctx = context.WithValue(ctx, ctxUIDKey, uid)
	ctx = context.WithValue(ctx, ctxUOIDKey, uoid)
	return ctx, nil
}

func unaryAuthInterceptor(
	ctx context.Context,
	req interface{},
	info *grpc.UnaryServerInfo,
	handler grpc.UnaryHandler,
) (interface{}, error) {
	ctx, err := withAuth(ctx)
	if err != nil {
		return nil, err
	}
	return handler(ctx, req)
}

func streamAuthInterceptor(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
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

func getUID(ctx context.Context) string {
	if v := ctx.Value(ctxUIDKey); v != nil {
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
