package web

import (
	"modb"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func GroupRoute(g *gin.Engine) {
	a := g.Group("/groups/:tid")
	{
		a.Use(getTid())
		a.GET("", GroupsGet)
	}

	b := g.Group("/group/:tid")
	{
		b.Use(getTid())
		b.POST("", GroupPost)
	}

	c := g.Group("/group/:tid/:gid")
	{
		c.Use(getTidAndGid())
		c.GET("", GroupIDGet)
		c.PUT("", GroupIDPut)
		c.DELETE("", GroupIDDelete)
	}
}
func GroupsGet(g *gin.Context) {
	log.Info("获取所有分组")

	toid := g.MustGet("toid").(primitive.ObjectID)

	response, err := modb.GroupsGet(toid)
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	okData(g, response)
}

func GroupIDGet(g *gin.Context) {
	log.Infof("获取分组")
	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)

	response, err := modb.GroupGet(toid, goid)
	if err != nil {
		internalServerError(g)
		return
	}

	okData(g, response)
}
func GroupPost(g *gin.Context) {
	log.Infof("获取主题")

	toid := g.MustGet("toid").(primitive.ObjectID)

	// 响应必须返回ID
	type response struct {
		ID string `json:"id"`
	}

	var req modb.RequestGroupPost
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	id, err := modb.GroupPost(toid, &req)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, response{ID: id})
}
func GroupIDPut(g *gin.Context) {
	log.Infof("修改分组")

	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)

	var req modb.RequestGroupPut

	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	if err := modb.GroupPut(toid, goid, &req); err != nil {
		internalServerError(g)
		return
	}

	ok(g)
}
func GroupIDDelete(g *gin.Context) {
	log.Infof("删除分组")

	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)

	err := modb.GroupDeleteOne(toid, goid)
	if err != nil {
		internalServerError(g)
		return
	}

	ok(g)
}
