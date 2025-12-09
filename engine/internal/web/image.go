package web

import (
	"fmt"
	"io"
	"strings"

	"github.com/acer-red/whisperingtime/engine/service/modb"
	"github.com/acer-red/whisperingtime/engine/util"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func RouterImageGet(g *gin.Engine) {
	a := g.Group("/image/:uid/:file")
	{
		a.GET("", ImageGet)
	}
}
func RouteImage(g *gin.Engine) {
	a := g.Group("/image/:file")
	{
		a.DELETE("", ImageDelete)
	}
	b := g.Group("/image")
	{
		b.POST("", ImagePost)
	}
}
func ImageGet(g *gin.Context) {
	log.Debugf("印迹图片提取")
	uid := g.Param("uid")
	name := g.Param("file")
	res, err := modb.ImageGet(uid, name)

	if err == util.ErrNoFound {
		notFound(g)
		return
	}
	if err != nil {
		internalServerError(g)
		return
	}

	okImage(g, res)
}
func ImagePost(g *gin.Context) {
	log.Infof("印迹图片创建")
	type request struct {
		Name string `json:"name"`
		URL  string `json:"url"`
	}
	uoid := g.MustGet("uoid").(primitive.ObjectID)
	uid := g.MustGet("uid").(string)
	contentType := g.Request.Header.Get("Content-Type")
	contentType = strings.ToLower(contentType)

	if contentType != "image/png" && contentType != "image/jpeg" {
		badRequest(g)
		return
	}
	name := fmt.Sprintf("%s.%s", util.CreateUUID(), contentType[6:])

	body, err := io.ReadAll(g.Request.Body)
	if err != nil {
		badRequest(g)
		return
	}
	if len(body) == 0 {
		badRequest(g)
		return
	}

	if err := modb.ImageCreate(name, body, uoid); err != nil {
		internalServerError(g)
		return
	}
	okData(g, request{
		Name: name,
		URL:  fmt.Sprintf("%s/image/%s/%s", g.MustGet("env").(Env).FullServerAddress, uid, name),
	})
}
func ImageDelete(g *gin.Context) {
	log.Infof("印迹图片删除")
	name := g.Param("file")

	err := modb.ImageDelete(name)
	if err == util.ErrNoFound {
		notFound(g)
		return
	}
	if err != nil {
		internalServerError(g)
		return
	}
	ok(g)
}
