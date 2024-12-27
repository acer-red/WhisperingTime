package web

import (
	"modb"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func DocRoute(g *gin.Engine) {
	a := g.Group("/docs/:gid")
	{
		a.Use(getGid())
		a.GET("", DocsGet)
	}

	b := g.Group("/doc/:gid")
	{
		b.Use(getGid())
		b.POST("", DocPost)
	}

	c := g.Group("/doc/:gid/:did")
	{
		c.Use(getGidAndDid())
		c.PUT("", DocIDPut)
		c.DELETE("", DocIDDelete)
	}
}

func DocsGet(g *gin.Context) {
	goid := g.MustGet("goid").(primitive.ObjectID)

	ret, err := modb.DocsGet(goid)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, ret)
}
func DocPost(g *gin.Context) {

	type response struct {
		ID string `json:"id"`
	}
	log.Info("创建文档")

	goid := g.MustGet("goid").(primitive.ObjectID)

	var req modb.RequestDocPost

	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	did, err := modb.DocPost(goid, &req)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	okData(g, response{ID: did})
}
func DocIDPut(g *gin.Context) {
	log.Info("更新文档")
	goid := g.MustGet("goid").(primitive.ObjectID)
	doid := g.MustGet("doid").(primitive.ObjectID)

	var req modb.RequestDocPut
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	if err := modb.DocPut(goid, doid, &req); err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	ok(g)
}
func DocIDDelete(g *gin.Context) {

	log.Info("删除文档")
	goid := g.MustGet("goid").(primitive.ObjectID)
	doid := g.MustGet("doid").(primitive.ObjectID)

	if err := modb.DocDelete(goid, doid); err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	ok(g)
}
