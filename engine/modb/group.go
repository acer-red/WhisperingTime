package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Group struct {
	Name string `json:"name" bson:"name"`
	ID   string `json:"id" bson:"gid"`
}

func GetGroupObjIDFromgID(gid string) (primitive.ObjectID, error) {

	identified := bson.D{{Key: "gid", Value: gid}}
	var result bson.M

	if err := db.Collection("group").FindOne(context.TODO(), identified).Decode(&result); err != nil {
		return primitive.NilObjectID, err
	}

	oid, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, nil
	}

	return oid, nil
}
func GroupGet(tid string) ([]Group, error) {
	var results []Group
	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {
		return nil, err
	}
	filter := bson.D{
		{Key: "_toid", Value: toid},
	}

	cursor, err := db.Collection("group").Find(context.TODO(), filter)
	if err != nil {
		return nil, err
	}

	for cursor.Next(context.TODO()) {
		var result Group
		err := cursor.Decode(&result)
		if err != nil {
			return nil, err
		}
		results = append(results, result)
	}

	if err := cursor.Err(); err != nil {
		return nil, err
	}

	return results, nil
}
func GroupPost(tid, groupname string) (string, error) {
	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {

		return "", err
	}
	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: groupname},
		{Key: "gid", Value: gid},
	}

	_, err = db.Collection("group").InsertOne(context.TODO(), data)

	if err != nil {

		return "", err
	}
	return gid, nil
}
func GroupPut(tid, groupname string, id string) error {

	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {
		return err
	}

	filter := bson.M{
		"_toid": toid,
		"gid":   id,
	}
	update := bson.M{
		"$set": bson.M{
			"name": groupname,
		},
	}

	_, err = db.Collection("group").UpdateOne(
		context.TODO(),
		filter,
		update,
		nil,
	)
	return err
}
func CreateGroupDefault(tid string) (string, error) {

	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {
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
		return "", err
	}
	return gid, nil
}
func DeleteGroupAll(tid string) error {
	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {
		return err
	}
	data := bson.D{
		{Key: "_toid", Value: toid},
	}

	_, err = db.Collection("group").DeleteMany(context.TODO(), data)
	if err != nil {
		return err
	}
	return err
}
func GroupDelete(gid string) error {
	filter := bson.M{
		"gid": gid,
	}
	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)
	return err
}
