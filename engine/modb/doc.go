package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type config struct {
	IsShowTool bool `json:"is_show_tool" bson:"is_show_tool"`
}
type Doc struct {
	Title     string  `json:"title" bson:"title"`
	Content   string  `json:"content" bson:"content"`
	PlainText string  `json:"plain_text" bson:"plain_text"`
	Level     int     `json:"level" bson:"level"`
	CRTime    string  `json:"crtime"`
	UPTime    string  `json:"uptime"`
	Config    *config `json:"config,omitempty" bson:"config"`
	ID        string  `json:"id" bson:"did"`
}

type RequestDocPost struct {
	Data struct {
		Content   string  `json:"content"`
		Title     string  `json:"title"`
		PlainText string  `json:"plain_text"`
		Level     int     `json:"level"`
		CRTime    string  `json:"crtime"`
		Config    *config `json:"config"`
	} `json:"data"`
}

type RequestDocPut struct {
	Doc Doc `json:"data"`
}

func DocsGet(goid primitive.ObjectID) ([]Doc, error) {
	var results []Doc

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
func DocPost(goid primitive.ObjectID, req *RequestDocPost) (string, error) {

	did := sys.CreateUUID()
	data := bson.D{
		{Key: "_goid", Value: goid},
		{Key: "did", Value: did},
		{Key: "title", Value: (*req).Data.Title},
		{Key: "content", Value: (*req).Data.Content},
		{Key: "plain_text", Value: (*req).Data.PlainText},
		{Key: "level", Value: (*req).Data.Level},
		{Key: "crtime", Value: (*req).Data.CRTime},
		{Key: "config", Value: (*req).Data.Config},
	}

	_, err := db.Collection("doc").InsertOne(context.TODO(), data)
	if err != nil {
		return "", err
	}

	return did, err
}
func DocPut(goid primitive.ObjectID, doid primitive.ObjectID, req *RequestDocPut) error {

	filter := bson.M{
		"_goid": goid,
		"_id":   doid,
	}

	data := bson.M{}
	var onlyLevel bool = true

	if (*req).Doc.Content != "" {
		data["content"] = (*req).Doc.Content
		data["plain_text"] = (*req).Doc.PlainText
		onlyLevel = false
	}

	if (*req).Doc.Title != "" {
		data["title"] = (*req).Doc.Title
		onlyLevel = false
	}

	if (*req).Doc.CRTime != "" {
		data["crtime"] = (*req).Doc.CRTime
	}

	if (*req).Doc.UPTime != "" {
		data["uptime"] = (*req).Doc.UPTime
	}

	if (*req).Doc.Title != "" {
		data["title"] = (*req).Doc.Title
		onlyLevel = false
	}

	if (*req).Doc.Config != nil {
		data["config"] = bson.M{
			"is_show_tool": (*req).Doc.Config.IsShowTool,
		}
		onlyLevel = false
	}

	if onlyLevel {
		data["level"] = (*req).Doc.Level
	}

	_, err := db.Collection("doc").UpdateOne(
		context.TODO(),
		filter,
		bson.M{
			"$set": data,
		},
		nil,
	)
	return err
}
func DocDelete(goid primitive.ObjectID, doid primitive.ObjectID) error {
	filter := bson.M{
		"_goid": goid,
		"_id":   doid,
	}
	_, err := db.Collection("doc").DeleteOne(context.TODO(),
		filter,
		nil,
	)
	return err
}

// 根据goid删除所有文档
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
