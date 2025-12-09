package cache

import (
	"context"
	"fmt"

	"github.com/redis/go-redis/v9"
)

// RedisConfig holds minimal redis connection info.
type RedisConfig struct {
	Address  string
	Password string
	DB       int
}

var rdb *redis.Client

// InitRedis initializes global redis client and performs a ping.
func InitRedis(cfg RedisConfig) error {
	if cfg.Address == "" {
		return fmt.Errorf("redis addr is empty")
	}
	rdb = redis.NewClient(&redis.Options{
		Addr:     cfg.Address,
		Password: cfg.Password,
		DB:       cfg.DB,
	})
	ctx := context.Background()
	if err := rdb.Ping(ctx).Err(); err != nil {
		return fmt.Errorf("redis ping failed: %w", err)
	}
	return nil
}

// Client returns the initialized redis client.
func Client() *redis.Client {
	return rdb
}
