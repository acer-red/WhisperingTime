package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type RequestThemePostDefaultGroup struct {
	Name     string `json:"name"`
	CRTime   string `json:"crtime"`
	Overtime string `json:"overtime"`
}

type RequestThemePost struct {
	Data struct {
		Name         string                       `json:"name"`
		CRTime       string                       `json:"crtime"`
		DefaultGroup RequestThemePostDefaultGroup `json:"default_group"`
	} `json:"data" `
}
type Theme struct {
	Name string `json:"name" bson:"name"`
	ID   string `json:"id" bson:"tid"`
}

// 输入uid，返回uoid和toid
func GetThemeObjID(uid string) (primitive.ObjectID, primitive.ObjectID, error) {
	uoid, err := UserGetObjectUID(uid)
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

// 输入tid，返回toid
func GetThemeObjIDFromTID(tid string) (primitive.ObjectID, error) {

	identified := bson.D{{Key: "tid", Value: tid}}
	var result bson.M

	if err := db.Collection("theme").FindOne(context.TODO(), identified).Decode(&result); err != nil {
		return primitive.NilObjectID, err
	}

	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, nil
	}

	return id, nil
}
func GetTheme(uid string) ([]Theme, error) {

	var results []Theme
	uoid, err := UserGetObjectUID(uid)
	if err != nil {
		return nil, err
	}

	filter := bson.D{
		{Key: "_uid", Value: uoid},
	}

	cursor, err := db.Collection("theme").Find(context.TODO(), filter)
	if err != nil {
		return nil, err
	}

	for cursor.Next(context.TODO()) {
		var result Theme
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
func CreateTheme(uid string, req *RequestThemePost) (string, error) {
	uoid, err := UserGetObjectUID(uid)
	if err != nil {
		return "", err
	}

	tid := sys.CreateUUID()
	theme := bson.D{
		{Key: "_uid", Value: uoid},
		{Key: "name", Value: req.Data.Name},
		{Key: "crtime", Value: req.Data.CRTime},
		{Key: "tid", Value: tid},
	}
	_, err = db.Collection("theme").InsertOne(context.TODO(), theme)
	return tid, err
}
func UpdateTheme(uid string, name string, tid string) error {

	_, toid, err := GetThemeObjID(uid)
	if err != nil {
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
func DeleteTheme(uid, tid string) error {

	// 根据uid返回toid
	_, toid, err := GetThemeObjID(uid)
	if err != nil {
		return err
	}

	// 根据toid返回所有goids
	goids, err := GetGOIDsFromTOID(toid)
	if err != nil {
		return err
	}

	for _, goid := range goids {

		// 根据goid删除所有文档
		if err := DocDeleteFromGOID(goid); err != nil {
			return err
		}

		// 根据goid删除分组
		if err := GroupDeleteFromGOID(goid); err != nil {
			return err
		}
	}

	filter := bson.M{
		"_id": toid,
	}
	_, err = db.Collection("theme").DeleteOne(context.TODO(),
		filter,
		nil,
	)
	return err
}
