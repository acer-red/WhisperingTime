package app

import (
	"flag"
	"fmt"

	log "github.com/tengfei-xy/go-log"
)

// Options holds CLI arguments.
type Options struct {
	ConfigPath string
	LogLevel   int
}

// ParseFlags collects CLI options once so multiple entrypoints can reuse them.
func ParseFlags() Options {
	opts := Options{ConfigPath: "config.yaml", LogLevel: log.LEVELINFOINT}
	flag.IntVar(&opts.LogLevel, "v", log.LEVELINFOINT, fmt.Sprintf("日志等级,%d-%d", log.LEVELFATALINT, log.LEVELDEBUG3INT))
	flag.StringVar(&opts.ConfigPath, "c", opts.ConfigPath, "配置文件路径")
	flag.Parse()
	return opts
}
