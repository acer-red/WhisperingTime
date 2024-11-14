package modb

import (
	"context"
	"errors"
	"net/http"
	"sys"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func ExistUser(db *mongo.Database) gin.HandlerFunc {

	return func(g *gin.Context) {
		uid := g.Query("uid")
		if uid == "" {
			g.AbortWithStatus(http.StatusBadRequest)
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
	coll := db.Collection("user")
	ctx := context.TODO()

	var result bson.M
	if err := coll.FindOne(ctx, bson.D{{Key: "uid", Value: uid}}).Decode(&result); err != nil {
		log.Error(err)
		return primitive.NilObjectID, err
	}
	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, errors.New("无法获取_id")
	}
	log.Debug3f("查找用户 uid=%s %s", uid, id.String())
	return id, nil
}
func IsExistThemeID(db *mongo.Database, uid primitive.ObjectID) (primitive.ObjectID, error) {
	coll := db.Collection("theme")
	ctx := context.TODO()

	identified := bson.D{{Key: "_uid", Value: uid}}
	var result bson.M

	if err := coll.FindOne(ctx, identified).Decode(&result); err != nil {
		return primitive.NilObjectID, err
	}

	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, nil
	}

	return id, nil
}

func InsertTheme(db *mongo.Database, obj_uid primitive.ObjectID, data *string) (string, error) {
	themeid := sys.CreateUUID()
	theme := bson.D{
		{Key: "_uid", Value: obj_uid},
		{Key: "theme", Value: bson.A{
			bson.D{
				{Key: "data", Value: data},
				{Key: "id", Value: themeid},
			},
		}},
	}
	coll := db.Collection("theme")
	_, err := coll.InsertOne(context.TODO(), theme)
	return themeid, err
}
func UpdateTheme(db *mongo.Database, theme_obj_id primitive.ObjectID, name string, id string) error {
	coll := db.Collection("theme")
	filter := bson.M{
		"_id": theme_obj_id,
	}
	update := bson.M{
		"$set": bson.M{
			"theme.$[elem].data": name, // Update the 'data' field to "666"
		},
	}
	// Define the array filters to match the specific element
	arrayFilters := options.ArrayFilters{
		Filters: []interface{}{
			bson.M{"elem.id": id},
		},
	}
	log.Debug3f("数据库更新 %s 过滤条件id=%s 更新值=%s", theme_obj_id.String(), id, name)
	// Update the document
	_, err := coll.UpdateOne(
		context.TODO(),
		filter,
		update,
		&options.UpdateOptions{
			ArrayFilters: &arrayFilters,
		},
	)

	return err
}
