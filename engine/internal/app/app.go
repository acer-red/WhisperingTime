package app

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	grpcserver "github.com/acer-red/whisperingtime/engine/internal/grpcserver"
	"github.com/acer-red/whisperingtime/engine/service/cache"
	"github.com/acer-red/whisperingtime/engine/service/minio"
	"github.com/acer-red/whisperingtime/engine/service/modb"
	"github.com/acer-red/whisperingtime/engine/util"
	log "github.com/tengfei-xy/go-log"
)

func Main() {
	if err := run(ParseFlags()); err != nil {
		log.Fatal(err)
	}
}

func run(opts Options) error {
	initEnv()
	cfg, err := initConfig(opts.ConfigPath)
	if err != nil {
		return err
	}

	initLog(opts.LogLevel)

	if err := initMongo(cfg); err != nil {
		return err
	}
	if err := initMinio(cfg); err != nil {
		return err
	}
	if err := initRedis(cfg); err != nil {
		return err
	}

	go waitForSignals()

	return grpcserver.Init(grpcserver.Config{
		Address:        cfg.GRPC.Address,
		Port:           cfg.GRPC.Port,
		PublicHTTPBase: cfg.Web.FullAddress(),
	})
}
func initEnv() {
	if os.Getenv(util.JwtEnvSecretKey) == "" {
		panic("HOME_JWT_SECRET unset")
	}
}
func initMongo(cfg Config) error {
	log.Infof("mongo连接中...")
	if err := modb.Init(cfg.mongoURI()); err != nil {
		return fmt.Errorf("init mongo: %w", err)
	}
	log.Infof("mongo连接成功!!")
	return nil
}

func initMinio(cfg Config) error {
	log.Infof("minio连接中...")
	if err := minio.Init(cfg.Minio); err != nil {
		return fmt.Errorf("init minio: %w", err)
	}
	log.Infof("minio连接成功!!")
	return nil
}

func initRedis(cfg Config) error {
	log.Infof("redis 连接中...")
	if err := cache.InitRedis(cfg.Redis); err != nil {
		return fmt.Errorf("init redis: %w", err)
	}
	log.Infof("redis 连接成功!!")
	return nil
}

func waitForSignals() {
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	sig := <-sigs
	log.Infof("收到信号: %s", sig)

	if err := modb.Disconnect(); err != nil {
		log.Error(err)
	}
	os.Exit(0)
}
