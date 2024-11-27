package web

import (
	"modb"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func GroupGet(g *gin.Context) {
	tid := g.Query("tid")
	log.Infof("获取分组 tid=%s", tid)

	response, err := modb.GetGroup(tid)
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	g.JSON(http.StatusOK, msgOK().setData(response))
}
