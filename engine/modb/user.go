package modb

import (
	"context"
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func ExistUser() gin.HandlerFunc {

	return func(g *gin.Context) {
		uid := g.Query("uid")
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
			return
		}

		// 创建用户
		_, err = db.Collection("user").InsertOne(ctx, identified)
		if err != nil {
			g.AbortWithStatus(http.StatusInternalServerError)
			return
		}
		log.Infof("新用户 uid=%s", uid)
	}
}
func UserGetObjectUID(uid string) (primitive.ObjectID, error) {
	var result bson.M

	if err := db.Collection("user").FindOne(context.TODO(), bson.D{{Key: "uid", Value: uid}}).Decode(&result); err != nil {
		return primitive.NilObjectID, err
	}

	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, errors.New("无法获取_id")
	}
	log.Debug3f("查找用户 uid=%s", uid)
	return id, nil
}
