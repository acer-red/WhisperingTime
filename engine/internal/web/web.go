package web

import (
	"fmt"

	"github.com/acer-red/whisperingtime/engine/service/modb"

	"github.com/gin-gonic/gin"
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

	// 日志中间件：打印请求体和响应体
	g.Use(loggerMiddleware())

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
	RouteBGJob(g)

	if env.SslEnable {
		err := g.RunTLS(fmt.Sprintf(":%d", env.Port), env.CrtFile, env.KeyFile)
		if err != nil {
			panic(err)
		}
		return
	} else {
		err := g.Run(fmt.Sprintf(":%d", env.Port))
		if err != nil {
			panic(err)
		}
	}

}
func setEnv(env Env) gin.HandlerFunc {
	return func(g *gin.Context) {
		g.Set("env", env)
	}
}
