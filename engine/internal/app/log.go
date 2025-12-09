package app

import (
	"fmt"

	log "github.com/tengfei-xy/go-log"
)

func initLog(level int) {
	log.SetLevelInt(level)
	_, g := log.GetLevel()
	fmt.Printf("日志等级:%s\n", g)
}
