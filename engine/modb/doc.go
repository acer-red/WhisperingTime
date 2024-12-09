package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type RequestDocPost struct {
	Data struct {
		Content string `json:"content"`
		Title   string `json:"title"`
		Level   int    `json:"level"`
	} `json:"data"`
	UpTime string `json:"uptime"`
}

type ReponseDocPut struct {
	Doc Doc `json:"data"`
	T   Time
}
type Doc struct {
	Title   string `json:"title" bson:"title"`
	Content string `json:"content" bson:"content"`
	Level   int    `json:"level" bson:"level"`
	ID      string `json:"id" bson:"did"`
}
type Time struct {
	UpTime string `json:"uptime"`
}

func DocsGet(gid string) ([]Doc, error) {
	var results []Doc
	goid, err := GetGOIDFromGID(gid)
	if err != nil {
		return nil, err
	}
	filter := bson.D{
		{Key: "_goid", Value: goid},
	}

	cursor, err := db.Collection("doc").Find(context.TODO(), filter)
	if err != nil {
		return nil, err
	}

	for cursor.Next(context.TODO()) {
		var result Doc
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
func DocPost(gid string, req *RequestDocPost) (string, error) {

	goid, err := GetGOIDFromGID(gid)
	if err != nil {
		return "", err
	}

	did := sys.CreateUUID()
	data := bson.D{
		{Key: "_goid", Value: goid},
		{Key: "did", Value: did},
		{Key: "content", Value: (*req).Data.Content},
		{Key: "title", Value: (*req).Data.Title},
		{Key: "level", Value: (*req).Data.Level},
	}

	_, err = db.Collection("doc").InsertOne(context.TODO(), data)
	if err != nil {
		return "", err
	}

	return did, err
}
func DocPut(gid string, req *ReponseDocPut) error {

	goid, err := GetGOIDFromGID(gid)
	if err != nil {
		return err
	}
	filter := bson.M{
		"_goid": goid,
		"did":   (*req).Doc.ID,
	}
	update := bson.M{
		"$set": bson.M{
			"content": (*req).Doc.Content,
			"title":   (*req).Doc.Title,
			"level":   (*req).Doc.Level,
		},
	}

	_, err = db.Collection("doc").UpdateOne(
		context.TODO(),
		filter,
		update,
		nil,
	)
	return err
}
func DocDelete(gid, did string) error {
	goid, err := GetGOIDFromGID(gid)
	if err != nil {
		return err
	}
	filter := bson.M{
		"_goid": goid,
		"did":   did,
	}
	_, err = db.Collection("doc").DeleteOne(context.TODO(),
		filter,
		nil,
	)
	return err
}
func DocDeleteFromGOID(goid primitive.ObjectID) error {
	data := bson.D{
		{Key: "_goid", Value: goid},
	}

	_, err := db.Collection("doc").DeleteMany(context.TODO(), data)
	if err != nil {
		return err
	}
	return err
}
