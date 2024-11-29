package web

import (
	"modb"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func GroupGet(g *gin.Context) {
	tid := g.Query("tid")
	log.Infof("获取分组 tid=%s", tid)

	response, err := modb.GroupGet(tid)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}

	okData(g, response)
}
func GroupPost(g *gin.Context) {
	tid := g.Query("tid")
	log.Infof("获取主题 tid=%s", tid)

	type request struct {
		Data struct {
			Name string `json:"name"`
		} `json:"data"`
		UpTime string `json:"uptime"`
	}
	type response struct {
		ID string `json:"id"`
	}

	var req request
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	id, err := modb.GroupPost(tid, req.Data.Name)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	okData(g, response{ID: id})
}
func GroupPut(g *gin.Context) {
	tid := g.Query("tid")
	log.Infof("获取主题 tid=%s", tid)

	type request struct {
		Data struct {
			Name string `json:"name"`
			ID   string `json:"id"`
		} `json:"data"`
		UpTime string `json:"uptime"`
	}
	var req request
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	if err := modb.GroupPut(tid, req.Data.Name, req.Data.ID); err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	ok(g)
}
func GroupDelete(g *gin.Context) {
	gid := g.Query("gid")
	log.Infof("获取分组 gid=%s", gid)

	err := modb.GroupDelete(gid)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}

	ok(g)
}
