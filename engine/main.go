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

type appS struct {
	loglevel int
}

var app appS

func init_mongo() {
	log.Infof("mongo连接中...")
	err := modb.Init()
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
	init_mongo()
	go quit()
	port := "21523"

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

	Theme := g.Group("/theme")
	{
		Theme.GET("", web.ThemeGet)
		Theme.POST("", web.ThemePost)
		Theme.PUT("", web.ThemePut)
		Theme.DELETE("", web.ThemeDelete)
	}
	Group := g.Group("/group")
	{
		Group.GET("", web.GroupGet)
		Group.POST("", web.GroupPost)
		Group.PUT("", web.GroupPut)
		Group.DELETE("", web.GroupDelete)
	}
	Doc := g.Group("/doc")
	{
		// Doc.GET("", web.DocGet)
		Doc.POST("", web.DocPost)
		// Doc.PUT("", web.DocPut)
		// Doc.DELETE("", web.DocDelete)
	}
	Docs := g.Group("/docs")
	{
		Docs.GET("", web.DocsGet)
		// Docs.POST("", web.DocsPost)
		// Docs.PUT("", web.DocsPut)
		// Docs.DELETE("", web.DocsDelete)
	}
	log.Infof("监听端口:%s", port)

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
