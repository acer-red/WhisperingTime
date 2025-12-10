package modb

import (
	"context"
	"errors"
	"net/http"
	"unicode/utf8"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
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
		if !utf8.ValidString(uid) {
			g.AbortWithStatusJSON(http.StatusBadRequest, "uid编码非法")
			return
		}
		g.Set("uid", uid)
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
		ret, err := db.Collection("user").InsertOne(ctx, identified)
		if err != nil {
			g.AbortWithStatus(http.StatusInternalServerError)
			return
		}
		g.Set("uoid", ret.InsertedID.(primitive.ObjectID))
		log.Infof("新用户 uid=%s", uid)
	}
}

// EnsureUser finds uid and returns its object id, creating a user if missing.
func EnsureUser(uid string) (primitive.ObjectID, error) {
	if !utf8.ValidString(uid) {
		return primitive.NilObjectID, errors.New("uid contains invalid utf-8")
	}
	ctx := context.TODO()
	identified := bson.D{{Key: "uid", Value: uid}}

	count, err := db.Collection("user").CountDocuments(ctx, identified)
	if err != nil {
		return primitive.NilObjectID, err
	}

	if count > 0 {
		return GetUOIDFromUID(uid)
	}

	ret, err := db.Collection("user").InsertOne(ctx, identified)
	if err != nil {
		return primitive.NilObjectID, err
	}

	uoid := ret.InsertedID.(primitive.ObjectID)
	log.Infof("新用户 uid=%s", uid)
	return uoid, nil
}

// UserDelete deletes a user by their object ID.
func UserDelete(uoid primitive.ObjectID) error {
	ctx := context.TODO()
	_, err := db.Collection("user").DeleteOne(ctx, bson.M{"_id": uoid})
	return err
}
