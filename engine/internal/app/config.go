package app

import (
	"fmt"
	"os"

	"github.com/acer-red/whisperingtime/engine/service/cache"
	"github.com/acer-red/whisperingtime/engine/service/minio"
	"gopkg.in/yaml.v3"
)

// Config represents full application configuration loaded from YAML.
type Config struct {
	Web   WebConfig    `yaml:"web"`
	GRPC  GRPCConfig   `yaml:"grpc"`
	Minio minio.Config `yaml:"minio"`
	DB    DBConfig     `yaml:"db"`
	Basic struct {
		Store string `yaml:"store"`
	} `yaml:"basic"`
	Redis     cache.RedisConfig `yaml:"redis"`
	Endpoints EndpointsConfig   `yaml:"endpoints"`
}

type WebConfig struct {
	Address   string `yaml:"address"`
	SslEnable bool   `yaml:"ssl_enable"`
	CrtFile   string `yaml:"crt_file"`
	KeyFile   string `yaml:"key_file"`
	Port      int    `yaml:"port"`
}

type GRPCConfig struct {
	Address string `yaml:"address"`
	Port    int    `yaml:"port"`
}

type DBConfig struct {
	Address  string `yaml:"address"`
	Database string `yaml:"database"`
	Port     int    `yaml:"port"`
	User     string `yaml:"user"`
	Password string `yaml:"password"`
}

type EndpointsConfig struct {
	Index string `yaml:"index"`
}

func initConfig(path string) (Config, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return Config{}, err
	}
	var cfg Config
	if err := yaml.Unmarshal(raw, &cfg); err != nil {
		return Config{}, err
	}
	cfg.applyDefaults()
	return cfg, nil
}

func (cfg *Config) applyDefaults() {
	cfg.Web.applyDefaults()
	cfg.GRPC.applyDefaults(cfg.Web.Address)
}

func (w *WebConfig) applyDefaults() {
	if w.Port <= 0 {
		w.Port = 21520
	}
	if w.Address == "" {
		w.Address = "127.0.0.1"
	}
}

func (g *GRPCConfig) applyDefaults(webAddr string) {
	if g.Port <= 0 {
		g.Port = 50051
	}
	if g.Address == "" {
		g.Address = webAddr
	}
}

// FullAddress returns the HTTP base used for public URLs.
func (w WebConfig) FullAddress() string {
	scheme := "http"
	if w.SslEnable {
		scheme = "https"
	}
	return fmt.Sprintf("%s://%s:%d", scheme, w.Address, w.Port)
}

// mongoURI builds the mongo connection string from config values.
func (cfg Config) mongoURI() string {
	return fmt.Sprintf("mongodb://%s:%s@%s:%d/%s",
		cfg.DB.User,
		cfg.DB.Password,
		cfg.DB.Address,
		cfg.DB.Port,
		cfg.DB.Database,
	)
}
