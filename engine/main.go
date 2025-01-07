package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/gin-gonic/gin"

	"modb"

	"web"

	log "github.com/tengfei-xy/go-log"
)

type App struct {
	loglevel int
	database string
}

var app App

func init_mongo() {
	log.Infof("mongo连接中...")
	str := os.Getenv("WTE_DATABASE")
	if str == "" {
		str = "mongodb://localhost:27017/"
	}
	err := modb.Init(str)
	if err != nil {
		log.Fatal(err)
	}
	log.Infof("mongo连接成功!!")
}
func init_log() {
	log.SetLevelInt(app.loglevel)
	_, g := log.GetLevel()
	fmt.Printf("日志等级:%s\n", g)
}
func init_flag() {
	flag.IntVar(&app.loglevel, "v", log.LEVELINFOINT, fmt.Sprintf("日志等级,%d-%d", log.LEVELFATALINT, log.LEVELDEBUG3INT))
	flag.Parse()
}
func main() {
	init_flag()
	init_log()

	port := "21523"
	log.Infof("监听端口:%s", port)

	gin.SetMode(gin.ReleaseMode)
	g := gin.Default()

	g.Use(modb.ExistUser())

	User := g.Group("/user")
	{
		// User.GET("", web.UserGet)
		User.POST("", web.UserPost)
		// User.PUT("", web.UserPut)
		// User.DELETE("", web.UserDelete)
	}
	web.ThemeRoute(g)
	web.GroupRoute(g)
	web.DocRoute(g)

	init_mongo()
	go quit()
	log.Info("启动成功")
	err := g.Run(":" + port)
	if err != nil {
		log.Fatal(err)
	}
}
func quit() {
	// 创建一个通道来接收信号通知
	sigs := make(chan os.Signal, 1)

	// 监听 SIGINT 和 SIGTERM 信号
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM, syscall.SIGINT)
	log.Infof("PID: %d", os.Getpid())
	// 阻塞等待信号
	sig := <-sigs
	fmt.Println(sig)

	err := modb.Disconnect()
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(1)
}
