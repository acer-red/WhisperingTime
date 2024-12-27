package modb

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
)

func ExistUser() gin.HandlerFunc {

	return func(g *gin.Context) {
		uid, _, ok := g.Request.BasicAuth()
		if !ok {
			g.AbortWithStatusJSON(http.StatusBadRequest, "缺少uid")
			return
		}
		if uid == "" {
			g.AbortWithStatusJSON(http.StatusBadRequest, "缺少uid")
			return
		}

		ctx := context.TODO()
		identified := bson.D{{Key: "uid", Value: uid}}

		count, err := db.Collection("user").CountDocuments(ctx, identified)
		if err != nil {
			g.AbortWithStatus(http.StatusInternalServerError)
			return
		}
		// 存在用户
		if count > 0 {
			uoid, err := GetUOIDFromUID(uid)
			if err != nil {
				log.Error(err)
				g.AbortWithStatus(http.StatusInternalServerError)
				return
			}
			g.Set("uoid", uoid)
			return
		}

		// 创建用户
		_, err = db.Collection("user").InsertOne(ctx, identified)
		if err != nil {
			g.AbortWithStatus(http.StatusInternalServerError)
			return
		}
		uoid, err := GetUOIDFromUID(uid)
		if err != nil {
			log.Error(err)
			g.AbortWithStatus(http.StatusInternalServerError)
			return
		}
		g.Set("uoid", uoid)
		log.Infof("新用户 uid=%s", uid)
	}
}
