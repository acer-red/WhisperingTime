package web

import (
	"io"
	"modb"

	"github.com/gin-gonic/gin"
)

func ImageRoute(g *gin.Engine) {

	a := g.Group("/image/:file")
	{
		// a.Use(getGidAndDid())
		a.GET("", imageGet)
		a.POST("", imagePost)
		// a.PUT("", imageIDPut)
		// a.DELETE("", imageIDDelete)
	}
}
func imageGet(g *gin.Context) {
	name := g.Param("file")
	res, err := modb.ImageGet(name)
	if err != nil {
		internalServerError(g)
		return
	}
	okPNG(g, res)
}
func imagePost(g *gin.Context) {
	name := g.Param("file")

	body, err := io.ReadAll(g.Request.Body)
	if err != nil {
		badRequest(g)
		return
	}
	if len(body) == 0 {
		badRequest(g)
		return
	}
	res, err := modb.ImageCreate(name, body)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, res)
}
