package web

import (
	"modb"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func DocsGet(g *gin.Context) {
	gid := g.Query("gid")
	if gid == "" {
		badRequest(g)
		return
	}
	ret, err := modb.DocsGet(gid)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, ret)
}
func DocPost(g *gin.Context) {

	type request struct {
		Data struct {
			Content string `json:"content"`
			Title   string `json:"title"`
		} `json:"data"`
		UpTime string `json:"uptime"`
	}

	type response struct {
		ID string `json:"id"`
	}

	gid := g.Query("gid")

	var req request

	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	did, err := modb.DocPost(gid, req.Data.Content, req.Data.Title)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	log.Infof("创建文档的 ID: %s", did)
	okData(g, response{ID: did})
}
