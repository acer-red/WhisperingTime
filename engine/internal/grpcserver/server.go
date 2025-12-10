package grpcserver

import (
	"fmt"
	"net"

	"github.com/acer-red/whisperingtime/engine/pb"
	log "github.com/tengfei-xy/go-log"
	"google.golang.org/grpc"
)

// Config holds gRPC server options.
type Config struct {
	Address        string
	Port           int
	PublicHTTPBase string // used to build image download URLs
}

// Start launches the gRPC server on a dedicated port.
func Init(cfg Config) error {
	addr := net.JoinHostPort(cfg.Address, fmt.Sprintf("%d", cfg.Port))
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		return err
	}

	s := grpc.NewServer(
		grpc.UnaryInterceptor(unaryAuthInterceptor),
		grpc.StreamInterceptor(streamAuthInterceptor),
	)

	svc := &Service{publicHTTPBase: cfg.PublicHTTPBase}
	pb.RegisterThemeServiceServer(s, svc)
	pb.RegisterGroupServiceServer(s, svc)
	pb.RegisterDocServiceServer(s, svc)
	pb.RegisterImageServiceServer(s, svc)
	pb.RegisterBackgroundJobServiceServer(s, svc)
	pb.RegisterFileServiceServer(s, svc)

	log.Infof("gRPC listening on %s", addr)
	return s.Serve(lis)
}
