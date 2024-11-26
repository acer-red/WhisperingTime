package modb

import (
	"context"
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func ExistUser(db *mongo.Database) gin.HandlerFunc {

	return func(g *gin.Context) {
		uid := g.Query("uid")
		if uid == "" {
			g.AbortWithStatusJSON(http.StatusBadRequest, "缺少uid")
			return
		}

		coll := db.Collection("user")
		ctx := context.TODO()
		identified := bson.D{{Key: "uid", Value: uid}}

		count, err := coll.CountDocuments(ctx, identified)
		if err != nil {
			g.AbortWithStatus(http.StatusBadRequest)
		}
		if count > 0 {
			return
		}

		_, err = coll.InsertOne(ctx, identified)
		if err != nil {
			g.AbortWithStatus(http.StatusBadRequest)
		}
		log.Infof("新用户 uid=%s", uid)
	}
}
func GetUserObjectUID(db *mongo.Database, uid string) (primitive.ObjectID, error) {
	var result bson.M

	if err := db.Collection("user").FindOne(context.TODO(), bson.D{{Key: "uid", Value: uid}}).Decode(&result); err != nil {
		log.Error(err)
		return primitive.NilObjectID, err
	}

	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, errors.New("无法获取_id")
	}
	log.Debug3f("查找用户 uid=%s", uid)
	return id, nil
}
