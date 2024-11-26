package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"modb"

	"web"

	log "github.com/tengfei-xy/go-log"
)

var mongosh *mongo.Client
var db *mongo.Database

type appS struct {
	loglevel int
}

var app appS

func init_mongo() {
	username := "wt"
	password := "SR7Yqb959q9k38qBFDKE"
	port := "28018"
	host := "124.223.15.220"
	database := "whisperingtime"
	uri := fmt.Sprintf("mongodb://%s:%s@%s:%s/%s", username, password, host, port, database)

	log.Infof("mongo连接中")

	clientOptions := options.Client().ApplyURI(uri)

	var err error
	mongosh, err = mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		log.Fatal(err)
	}
	db = mongosh.Database(database)
	err = mongosh.Ping(context.TODO(), nil)
	if err != nil {
		log.Fatal(err)
	}

	log.Infof("mongo连接成功!")
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

	g.Use(modb.ExistUser(db))

	g.POST("/user", func(g *gin.Context) {
		web.UserPost(g, db)
	})
	g.POST("/theme", func(g *gin.Context) {
		web.PostTheme(g, db)
	})

	g.GET("/theme", func(g *gin.Context) {
		web.GetTheme(g, db)
	})
	g.DELETE("/theme", func(g *gin.Context) {
		web.DeleteTheme(g, db)
	})
	g.PUT("/theme", func(g *gin.Context) {
		web.PutTheme(g, db)
	})
	g.GET("/group", func(g *gin.Context) {
		web.GetGroup(g, db)
	})
	g.POST("/doc", func(g *gin.Context) {
		web.DocPost(g, db)
	})

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

	err := mongosh.Disconnect(context.TODO())
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(1)
}
