package modb

import (
	"context"
	"sys"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type Group struct {
	Name string `json:"name" bson:"name"`
	ID   string `json:"id" bson:"gid"`
}

func GetGroup(db *mongo.Database, tid string) ([]Group, error) {
	var results []Group
	toid, err := GetThemeObjIDFromTID(db, tid)
	if err != nil {
		log.Error(err)
		return nil, err
	}
	filter := bson.D{
		{Key: "_toid", Value: toid},
	}

	cursor, err := db.Collection("group").Find(context.TODO(), filter)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	// 遍历结果
	for cursor.Next(context.TODO()) {
		var result Group
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
func CreateGroupDefault(db *mongo.Database, tid string) (string, error) {

	toid, err := GetThemeObjIDFromTID(db, tid)
	if err != nil {
		log.Error(err)
		return "", err
	}
	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: "默认分组"},
		{Key: "gid", Value: gid},
		{Key: "default", Value: true},
	}

	_, err = db.Collection("group").InsertOne(context.TODO(), data)

	if err != nil {
		log.Error(err)
		return "", err
	}
	return gid, nil
}
func CreateGroup(db *mongo.Database, tid, groupname string) (string, error) {

	toid, err := GetThemeObjIDFromTID(db, tid)
	if err != nil {
		log.Error(err)
		return "", err
	}
	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: groupname},
		{Key: "gid", Value: gid},
	}
	coll := db.Collection("group")

	_, err = coll.InsertOne(context.TODO(), data)

	if err != nil {
		log.Error(err)
		return "", err
	}
	return gid, nil
}
func DeleteGroupAll(db *mongo.Database, tid string) error {
	toid, err := GetThemeObjIDFromTID(db, tid)
	if err != nil {
		log.Error(err)
		return err
	}
	data := bson.D{
		{Key: "_toid", Value: toid},
	}

	_, err = db.Collection("group").DeleteMany(context.TODO(), data)
	if err != nil {
		log.Error(err)
	}
	return err
}
