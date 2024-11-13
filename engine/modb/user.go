package modb

import (
	"context"
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func ExistUser(db *mongo.Database) gin.HandlerFunc {

	return func(g *gin.Context) {
		InternalServer := fmt.Errorf("内部系统错误")
		uid := g.Query("uid")
		if uid == "" {
			g.String(http.StatusBadRequest, "uid")
			return
		}

		coll := db.Collection("user")
		ctx := context.TODO()
		identified := bson.D{{Key: "uid", Value: uid}}

		// 使用 CountDocuments 检查用户是否存在
		count, err := coll.CountDocuments(ctx, identified)
		if err != nil {
			log.Error(InternalServer)
			g.AbortWithError(http.StatusInternalServerError, InternalServer)
		}
		if count > 0 {
			return
		}

		// 使用唯一索引或更严格的检查以避免重复插入
		_, err = coll.InsertOne(ctx, identified)
		if err != nil {
			log.Error(InternalServer)
			g.AbortWithError(http.StatusInternalServerError, InternalServer)
		}
		log.Infof("新用户 uid=%s", uid)
	}
}
func GetUserObjectID(db *mongo.Database, uid string) (primitive.ObjectID, error) {
	coll := db.Collection("user")
	ctx := context.TODO()

	identified := bson.D{{Key: "uid", Value: uid}}
	var result bson.M
	if err := coll.FindOne(ctx, identified).Decode(&result); err != nil {
		log.Error(err)
		return primitive.NilObjectID, err
	}
	// 提取 _id
	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, errors.New("无法获取_id")
	}

	return id, nil
}
