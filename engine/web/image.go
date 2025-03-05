package web

import (
	"fmt"
	"io"
	"modb"
	"strings"
	"sys"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func ImageRoute(g *gin.Engine) {

	a := g.Group("/image/:file")
	{
		// a.Use(getGidAndDid())
		a.GET("", imageGet)
		// a.PUT("", imageIDPut)
		a.DELETE("", imageDelete)
	}
	b := g.Group("/image")
	{
		b.POST("", imagePost)
	}

}
func imageGet(g *gin.Context) {
	log.Debugf("图片提取")
	name := g.Param("file")
	res, err := modb.ImageGet(name)

	if err == sys.ERR_NO_FOUND {
		notFound(g)
		return
	}
	if err != nil {
		internalServerError(g)
		return
	}

	okImage(g, res)
}
func imagePost(g *gin.Context) {
	log.Infof("图片创建")
	type request struct {
		Name string `json:"name"`
	}
	contentType := g.Request.Header.Get("Content-Type")
	contentType = strings.ToLower(contentType)

	if contentType != "image/png" && contentType != "image/jpeg" {
		badRequest(g)
		return
	}
	name := fmt.Sprintf("%s.%s", sys.CreateUUID(), contentType[6:])

	body, err := io.ReadAll(g.Request.Body)
	if err != nil {
		badRequest(g)
		return
	}
	if len(body) == 0 {
		badRequest(g)
		return
	}

	if err := modb.ImageCreate(name, body); err != nil {
		internalServerError(g)
		return
	}
	okData(g, request{
		Name: name,
	})
}
func imageDelete(g *gin.Context) {
	log.Infof("图片删除")
	name := g.Param("file")

	err := modb.ImageDelete(name)
	if err == sys.ERR_NO_FOUND {
		notFound(g)
		return
	}
	if err != nil {
		internalServerError(g)
		return
	}
	ok(g)
}
