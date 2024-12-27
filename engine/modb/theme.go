package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Theme struct {
	Name string `json:"name" bson:"name"`
	ID   string `json:"id" bson:"tid"`
}

type RequestThemePut struct {
	Data struct {
		Name   string `json:"name"`
		UPTime string `json:"uptime"`
	} `json:"data" `
}

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

// 根据UOID找到所有的主题
func GetTheme(uoid primitive.ObjectID) ([]Theme, error) {

	var results []Theme

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
func CreateTheme(uoid primitive.ObjectID, req *RequestThemePost) (primitive.ObjectID, string, error) {

	tid := sys.CreateUUID()
	theme := bson.D{
		{Key: "_uid", Value: uoid},
		{Key: "name", Value: req.Data.Name},
		{Key: "crtime", Value: req.Data.CRTime},
		{Key: "tid", Value: tid},
	}
	ret, err := db.Collection("theme").InsertOne(context.TODO(), theme)

	return ret.InsertedID.(primitive.ObjectID), tid, err
}
func UpdateTheme(toid primitive.ObjectID, req *RequestThemePut) error {

	filter := bson.M{
		"_id": toid,
	}
	update := bson.M{
		"$set": bson.M{
			"name": req.Data.Name,
		},
	}

	_, err := db.Collection("theme").UpdateOne(
		context.TODO(),
		filter,
		update,
		nil,
	)
	return err
}
func DeleteTheme(toid primitive.ObjectID) error {

	// 根据toid返回所有goids
	goids, err := GetGOIDsFromTOID(toid)
	if err != nil {
		return err
	}

	for _, goid := range goids {

		if err := DocDeleteFromGOID(goid); err != nil {
			return err
		}

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
