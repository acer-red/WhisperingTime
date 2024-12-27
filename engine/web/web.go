package web

import (
	"modb"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func getTid() gin.HandlerFunc {
	return func(g *gin.Context) {
		tid := g.Param("tid")
		toid, err := modb.GetTOIDFromTID(tid)
		if err != nil {
			log.Error(err)
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return
		}
		g.Set("toid", toid)
		g.Next()
	}
}
func getGid() gin.HandlerFunc {
	return func(g *gin.Context) {

		gid := g.Param("gid")
		if gid == "" {
			log.Error("gid is empty")
			g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
			return
		}
		goid, err := modb.GetGOIDFromGID(gid)
		if err != nil {
			log.Error(err)
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return
		}

		g.Set("goid", goid)
		g.Next()
	}
}

func getTidAndGid() gin.HandlerFunc {
	return func(g *gin.Context) {

		tid := g.Param("tid")
		if tid == "" {
			log.Error("tid is empty")
			g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
			return
		}
		toid, err := modb.GetTOIDFromTID(tid)
		if err != nil {
			log.Error(err)
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return
		}
		g.Set("toid", toid)

		gid := g.Param("gid")
		if gid == "" {
			log.Error("gid is empty")
			g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
			return
		}
		goid, err := modb.GetGOIDFromGID(gid)
		if err != nil {
			log.Error(err)
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return
		}

		g.Set("goid", goid)
		g.Next()
	}
}

func getGidAndDid() gin.HandlerFunc {
	return func(g *gin.Context) {

		gid := g.Param("gid")
		if gid == "" {
			log.Error("gid is empty")
			g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
			return
		}
		goid, err := modb.GetGOIDFromGID(gid)
		if err != nil {
			log.Error(err)
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return
		}

		g.Set("goid", goid)

		did := g.Param("did")
		if did == "" {
			log.Error("did is empty")
			g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
			return
		}
		doid, err := modb.GetDOIDFromGOIDAndDID(goid, did)
		if err != nil {
			log.Error(err)
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return
		}
		g.Set("doid", doid)

		g.Next()
	}
}
