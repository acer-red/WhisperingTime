package web

import (
	"modb"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func ThemeRoute(g *gin.Engine) {
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

func ThemesGet(g *gin.Context) {
	log.Info("获取所有主题")
	uoid := g.MustGet("uoid").(primitive.ObjectID)

	response, err := modb.GetTheme(uoid)
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	g.JSON(http.StatusOK, msgOK().setData(response))
}

func ThemePost(g *gin.Context) {
	log.Info("插入主题")
	type response struct {
		ID string `json:"id"`
	}
	uoid := g.MustGet("uoid").(primitive.ObjectID)

	var req modb.RequestThemePost
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
		return
	}

	toid, tid, err := modb.CreateTheme(uoid, &req)
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	if _, err := modb.GroupCreateDefault(toid, req.Data.DefaultGroup); err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	okData(g, response{ID: tid})
}
func ThemeIDPut(g *gin.Context) {
	log.Info("主题更新")

	toid := g.MustGet("toid").(primitive.ObjectID)

	var req modb.RequestThemePut
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
		return
	}
	if err := modb.UpdateTheme(toid, &req); err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	ok(g)
}
func ThemeIDDelete(g *gin.Context) {
	log.Info("主题删除")
	toid := g.MustGet("toid").(primitive.ObjectID)

	err := modb.DeleteTheme(toid)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	ok(g)
}
