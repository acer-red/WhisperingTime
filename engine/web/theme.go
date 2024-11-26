package web

import (
	"modb"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/mongo"
)

func GetTheme(g *gin.Context, db *mongo.Database) {

	uid := g.Query("uid")
	log.Infof("获取主题 uid=%s", uid)

	response, err := modb.GetTheme(db, uid)
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	g.JSON(http.StatusOK, msgOK().setData(response))
}
func PostTheme(g *gin.Context, db *mongo.Database) {
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

	tid, err := modb.CreateTheme(db, uid, &req.Data.Name)
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	if _, err := modb.CreateGroupDefault(db, tid); err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Infof("插入主题 %s data:%s uptime:%s", uid, req.Data.Name, req.UpTime)
	g.JSON(http.StatusOK, msgOK().setData(response{Name: req.Data.Name, ID: tid}))
}
func PutTheme(g *gin.Context, db *mongo.Database) {
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
	if err := modb.UpdateTheme(db, uid, req.Data.Name, req.Data.ID); err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Debug3f("主题更新 uid=%s 更新值=%s", uid, req.Data.Name)

	g.JSON(http.StatusOK, msgOK().setData(response{Name: req.Data.Name, ID: req.Data.ID}))
}
func DeleteTheme(g *gin.Context, db *mongo.Database) {
	tid := g.Query("themeid")

	if tid == "" {
		log.Errorf(mstrNoThemeID)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgNoParam().setMSG(mstrNoThemeID))
		return
	}

	uid := g.Query("uid")

	if err := modb.DeleteGroupAll(db, tid); err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Infof("删除分组 uid:%s tid:%s", uid, tid)

	err := modb.DeleteTheme(db, uid, tid)
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Infof("删除主题 uid:%s tid:%s", uid, tid)

	g.JSON(http.StatusOK, msgOK())
}
