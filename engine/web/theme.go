package web

import (
	"modb"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func RouteTheme(g *gin.Engine) {
	a := g.Group("/themes")
	{
		a.GET("", ThemesGet)
	}
	b := g.Group("/theme")
	{
		b.POST("", ThemePost)
	}
	c := g.Group("/theme/:tid")
	{
		c.Use(getTid())
		c.PUT("", ThemeIDPut)
		c.DELETE("", ThemeIDDelete)
	}
}

//  获取所有主题
//  GET /themes
//  参数说明
//  : 无参数，返回所有主题的数据
//  ?doc=1: 返回所有主题的数据以及主题对应的印迹
//  ?doc=1&id=1: 返回所有主题以及主题对应的印迹和ID
//  ?doc=1&detail=1: 返回所有主题以及主题、组、印迹的具体属性数据

func ThemesGet(g *gin.Context) {
	uoid := g.MustGet("uoid").(primitive.ObjectID)

	has_doc := g.Query("doc") != ""
	has_id := g.Query("id") != ""
	has_detail := g.Query("detail") == "1"

	// 仅有在has_id存在时，has_doc才有意义
	has_doc = has_doc && !has_id

	if len(g.Request.URL.Query()) == 0 || (has_doc && has_id) {
		log.Info("获取所有主题")

		response, err := modb.ThemesGet(uoid)
		if err != nil {
			internalServerError(g)
			return
		}
		okData(g, response)
		return
	}

	if has_detail {
		log.Info("获取所有主题（细节）")
		response, err := modb.ThemesGetAndDocsDetail(uoid, has_id)
		if err != nil {
			internalServerError(g)
			return
		}
		okData(g, response)
		return
	}

	log.Info("获取所有主题（印迹）")
	response, err := modb.ThemesGetAndDocs(uoid, has_id)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, response)
}
func ThemePost(g *gin.Context) {
	log.Info("插入主题")
	type response struct {
		ID string `json:"id"`
	}
	uoid := g.MustGet("uoid").(primitive.ObjectID)

	var req modb.RequestThemePost
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	toid, tid, err := modb.ThemeCreate(uoid, &req)
	if err != nil {
		internalServerError(g)
		return
	}

	if _, err := modb.GroupCreateDefault(toid, req.Data.DefaultGroup); err != nil {
		internalServerError(g)
		return
	}
	okData(g, response{ID: tid})
}
func ThemeIDPut(g *gin.Context) {
	log.Info("主题更新")

	toid := g.MustGet("toid").(primitive.ObjectID)

	var req modb.RequestThemePut
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}
	if err := modb.ThemeUpdate(toid, &req); err != nil {
		internalServerError(g)
		return
	}
	ok(g)
}
func ThemeIDDelete(g *gin.Context) {
	log.Info("主题删除")
	toid := g.MustGet("toid").(primitive.ObjectID)

	err := modb.ThemeDelete(toid)
	if err != nil {
		internalServerError(g)
		return
	}
	ok(g)
}
