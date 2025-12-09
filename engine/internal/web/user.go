package web

import (
	"github.com/gin-gonic/gin"
)

func RouteUser(g *gin.Engine) {
	User := g.Group("/user")
	{
		User.POST("", UserPost)
	}
}
func UserPost(g *gin.Context) {

}
