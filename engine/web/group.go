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

	type response struct {
		ID string `json:"id"`
	}

	var req modb.RequestGroupPost
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	id, err := modb.GroupPost(tid, &req)
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

	type response struct {
		ID string `json:"id"`
	}

	var req modb.RequestGroupPut
	var res response
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	if err := modb.GroupPut(tid, &req); err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}

	res.ID = tid
	okData(g, res)
}
func GroupDelete(g *gin.Context) {
	gid := g.Query("gid")
	log.Infof("获取分组 gid=%s", gid)

	err := modb.GroupDeleteFromGID(gid)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}

	ok(g)
}
