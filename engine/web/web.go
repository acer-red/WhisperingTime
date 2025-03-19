package web

import (
	"fmt"
	"modb"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

type Env struct {
	FullServerAddress string

	SslEnable bool
	CrtFile   string
	KeyFile   string
	Port      int
}

func Init(env Env) {
	gin.SetMode(gin.ReleaseMode)
	g := gin.Default()

	// 获取图片时不需要通过header来验证用户
	RouterImageGet(g)

	// 检查请求头以验证用户
	g.Use(modb.ExistUser())
	g.Use(setEnv(env))

	RouteUser(g)
	RouteTheme(g)
	RouteGroup(g)
	RouteDoc(g)
	RouteImage(g)

	log.Infof("API: %s", env.FullServerAddress)
	log.Info("启动监听...")

	if env.SslEnable {
		err := g.RunTLS(fmt.Sprintf(":%d", env.Port), env.CrtFile, env.KeyFile)
		if err != nil {
			log.Fatal(err)
		}
		return
	} else {
		err := g.Run(fmt.Sprintf(":%d", env.Port))
		if err != nil {
			log.Fatal(err)
		}
	}

}
func setEnv(env Env) gin.HandlerFunc {
	return func(g *gin.Context) {
		g.Set("env", env)
	}
}
