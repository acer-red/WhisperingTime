package modb

import (
	"context"
	"sys"

	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type Theme struct {
	Name string `json:"name" bson:"name"`
	ID   string `json:"id" bson:"tid"`
}

func GetThemeObjID(db *mongo.Database, uid string) (primitive.ObjectID, primitive.ObjectID, error) {
	uoid, err := GetUserObjectUID(db, uid)
	if err != nil {
		return primitive.NilObjectID, primitive.NilObjectID, err
	}

	coll := db.Collection("theme")
	ctx := context.TODO()

	identified := bson.D{{Key: "_uid", Value: uoid}}
	var result bson.M

	if err := coll.FindOne(ctx, identified).Decode(&result); err != nil {
		return primitive.NilObjectID, primitive.NilObjectID, err
	}

	toid, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, primitive.NilObjectID, nil
	}

	return uoid, toid, nil
}
func GetThemeObjIDFromTOID(db *mongo.Database, uid, toid string) (primitive.ObjectID, error) {

	uoid, err := GetUserObjectUID(db, uid)
	if err != nil {
		return primitive.NilObjectID, err
	}

	coll := db.Collection("theme")
	ctx := context.TODO()

	identified := bson.D{{Key: "_uid", Value: uoid}}
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
func CreateTheme(db *mongo.Database, uid string, name *string) (string, error) {
	// uoid, toid, err := GetThemeObjID(db, uid)
	// if err != nil {
	// 	return "", err
	// }
	// if isNil(toid) {
	// 	return createTheme(toid, data)
	// }
	uoid, err := GetUserObjectUID(db, uid)
	if err != nil {
		return "", err
	}

	tid := sys.CreateUUID()
	theme := bson.D{
		{Key: "_uid", Value: uoid},
		{Key: "name", Value: name},
		{Key: "tid", Value: tid},
	}
	_, err = db.Collection("theme").InsertOne(context.TODO(), theme)
	return tid, err

}

func GetTheme(db *mongo.Database, uid string) ([]Theme, error) {

	var results []Theme
	uoid, err := GetUserObjectUID(db, uid)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	filter := bson.D{
		{Key: "_uid", Value: uoid},
	}

	cursor, err := db.Collection("theme").Find(context.TODO(), filter)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	// 遍历结果
	for cursor.Next(context.TODO()) {
		var result Theme
		err := cursor.Decode(&result)
		if err != nil {
			log.Error(err)
			return nil, err
		}
		results = append(results, result)
	}
	// 检查错误
	if err := cursor.Err(); err != nil {
		log.Error(err)
		return nil, err
	}

	return results, nil
}
func UpdateTheme(db *mongo.Database, uid string, name string, tid string) error {

	_, toid, err := GetThemeObjID(db, uid)
	if err != nil {
		log.Error(err)
		return err
	}

	filter := bson.M{
		"_id": toid,
		"tid": tid,
	}
	update := bson.M{
		"$set": bson.M{
			"name": name,
		},
	}

	_, err = db.Collection("theme").UpdateOne(
		context.TODO(),
		filter,
		update,
		nil,
	)
	return err
}
func DeleteTheme(db *mongo.Database, uid, tid string) error {
	uoid, err := GetUserObjectUID(db, uid)
	if err != nil {
		log.Error(err)
		return err
	}
	filter := bson.M{
		"_uid": uoid,
		"tid":  tid,
	}
	_, err = db.Collection("theme").DeleteOne(context.TODO(),
		filter,
		nil,
	)
	return err
}

// func addTheme(toid primitive.ObjectID, data *string) (string, error) {

// 	tid := sys.CreateUUID()
// 	filter := bson.M{"_id": toid}
// 	update := bson.M{"$push": bson.M{"theme": bson.M{"data": data, "id": tid}}}

// 	_, err := db.Collection("theme").UpdateOne(context.TODO(), filter, update)
// 	return tid, err
// }
