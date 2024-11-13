package main

import (
	"context"
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

func init_mongo() {
	// 替换为您自己的连接字符串
	username := "wt"
	password := "SR7Yqb959q9k38qBFDKE"
	port := "28018"
	host := "124.223.15.220"
	database := "whisperingtime"
	uri := fmt.Sprintf("mongodb://%s:%s@%s:%s/%s", username, password, host, port, database)

	// 创建客户端选项
	clientOptions := options.Client().ApplyURI(uri)

	// 连接到 MongoDB
	var err error
	mongosh, err = mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		log.Fatal(err)
	}
	db = mongosh.Database(database)
	// 检查连接
	err = mongosh.Ping(context.TODO(), nil)
	if err != nil {
		log.Fatal(err)
	}

	log.Infof("mongo连接成功!")
}
func init_log() {
	log.SetLevelDebug()
	_, g := log.GetLevel()
	fmt.Printf("日志等级:%s\n", g)
}

func main() {
	init_log()
	init_mongo()
	go quit()

	gin.SetMode(gin.ReleaseMode)
	g := gin.Default()

	g.Use(modb.ExistUser(db))

	port := "21523"
	g.POST("/doc", func(g *gin.Context) {
		web.DOCPost(g, db)
	})

	g.POST("/theme", func(g *gin.Context) {
		web.THEMEPost(g, db)
	})

	g.GET("/theme", func(g *gin.Context) {
		web.THEMEGet(g, db)
	})

	g.POST("/user", func(g *gin.Context) {
		web.USERPost(g, db)
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
	fmt.Println("收到信号:", sig)

	err := mongosh.Disconnect(context.TODO())
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(1)
}
