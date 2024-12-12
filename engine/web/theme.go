package web

import (
	"modb"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func ThemeGet(g *gin.Context) {

	uid := g.Query("uid")
	log.Infof("获取主题 uid=%s", uid)

	response, err := modb.GetTheme(uid)
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	g.JSON(http.StatusOK, msgOK().setData(response))
}
func ThemePost(g *gin.Context) {

	type response struct {
		Name string `json:"name"`
		ID   string `json:"id"`
	}

	var req modb.RequestThemePost
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
		return
	}
	uid := g.Query("uid")

	tid, err := modb.CreateTheme(uid, &req)
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	if _, err := modb.CreateGroupDefault(tid, req.CRTime); err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Infof("插入主题 %s data:%s crtime:%s", uid, req.Data.Name, req.CRTime)
	g.JSON(http.StatusOK, msgOK().setData(response{Name: req.Data.Name, ID: tid}))
}
func ThemePut(g *gin.Context) {
	type request struct {
		Data struct {
			Name string `json:"name"`
			ID   string `json:"id"`
		} `json:"data" `
		UpTime string `json:"uptime"`
	}
	type response struct {
		Name string `json:"name"`
		ID   string `json:"id"`
	}
	var req request
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
		return
	}
	uid := g.Query("uid")
	if err := modb.UpdateTheme(uid, req.Data.Name, req.Data.ID); err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Debug3f("主题更新 uid=%s 更新值=%s", uid, req.Data.Name)

	g.JSON(http.StatusOK, msgOK().setData(response{Name: req.Data.Name, ID: req.Data.ID}))
}
func ThemeDelete(g *gin.Context) {
	tid := g.Query("tid")

	if tid == "" {
		log.Errorf(mstrNoThemeID)
		badRequest(g)
		return
	}

	uid := g.Query("uid")

	err := modb.DeleteTheme(uid, tid)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	log.Infof("删除主题 uid:%s tid:%s", uid, tid)

	ok(g)
}
