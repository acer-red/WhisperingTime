package modb

import (
	"context"
	"time"

	"github.com/tengfei-xy/whisperingtime/engine/sys"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"

	m "github.com/tengfei-xy/whisperingtime/engine/model"
)

type RequestDocPost struct {
	Data struct {
		Content   string       `json:"content"`
		Title     string       `json:"title"`
		PlainText string       `json:"plain_text"`
		Level     int32        `json:"level"`
		CreateAt  string       `json:"createAt"`
		Config    *m.DocConfig `json:"config"`
	} `json:"data"`
}

type RequestDocPut struct {
	Doc struct {
		Title     *string      `json:"title,omitempty" bson:"title"`
		Content   *string      `json:"content,omitempty" bson:"content"`
		PlainText *string      `json:"plain_text,omitempty" bson:"plain_text"`
		Level     *int32       `json:"level,omitempty" bson:"level"`
		CreateAt  *string      `json:"createAt,omitempty"`
		UpdateAt  *string      `json:"updateAt,omitempty"`
		Config    *m.DocConfig `json:"config,omitempty" bson:"config"`
		ID        *string      `json:"id" bson:"did"`
	} `json:"data"`
}
type DocFilter struct {
	Year  int `json:"year"`
	Month int `json:"month"`
}

func DocsGet(goid primitive.ObjectID, f DocFilter) ([]m.Doc, error) {

	var results []m.Doc

	filter := bson.D{
		{Key: "_goid", Value: goid},
	}
	if f.Year != 0 && f.Month != 0 {
		filter = append(filter, bson.E{Key: "createAt", Value: bson.M{
			"$gte": time.Date(f.Year, time.Month(f.Month), 1, 0, 0, 0, 0, time.Local),
			"$lt":  time.Date(f.Year, time.Month(f.Month+1), 1, 0, 0, 0, 0, time.Local),
		}})
	}
	cursor, err := db.Collection("doc").Find(context.TODO(), filter)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	for cursor.Next(context.TODO()) {
		var doc bson.M
		err := cursor.Decode(&doc)
		if err != nil {
			log.Error(err)
			return nil, err
		}
		results = append(results, m.Doc{
			Title:     doc["title"].(string),
			Content:   doc["content"].(string),
			PlainText: doc["plain_text"].(string),
			Level:     doc["level"].(int32),
			CreateAt:  doc["createAt"].(primitive.DateTime).Time(),
			UpdateAt:  doc["updateAt"].(primitive.DateTime).Time(),
			Config: &m.DocConfig{
				IsShowTool: doc["config"].(bson.M)["is_show_tool"].(bool),
			},
			ID: doc["did"].(string),
		})
	}

	if err := cursor.Err(); err != nil {
		log.Error(err)
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
		{Key: "createAt", Value: sys.StringtoTime((*req).Data.CreateAt)},
		{Key: "updateAt", Value: sys.StringtoTime((*req).Data.CreateAt)},
		{Key: "config", Value: (*req).Data.Config},
	}

	_, err := db.Collection("doc").InsertOne(context.TODO(), data)
	if err != nil {
		return "", err
	}

	if err := refreshGroupUpdateAt(goid, true); err != nil {
		return "", err
	}

	return did, nil
}
func DocPut(goid primitive.ObjectID, doid primitive.ObjectID, req *RequestDocPut) error {

	filter := bson.M{
		"_goid": goid,
		"_id":   doid,
	}

	m := bson.M{}

	if (*req).Doc.Content != nil {
		m["content"] = (*req).Doc.Content
		m["plain_text"] = (*req).Doc.PlainText
	}

	if (*req).Doc.Title != nil {
		m["title"] = (*req).Doc.Title
	}

	if (*req).Doc.CreateAt != nil {
		m["createAt"] = sys.StringtoTime(*(*req).Doc.CreateAt)
	}

	if (*req).Doc.UpdateAt != nil {
		m["updateAt"] = sys.StringtoTime(*(*req).Doc.UpdateAt)
	}

	if (*req).Doc.Title != nil {
		m["title"] = (*req).Doc.Title
	}

	if (*req).Doc.Config != nil {
		m["config"] = bson.M{
			"is_show_tool": (*req).Doc.Config.IsShowTool,
		}
	}

	if (*req).Doc.Level != nil {
		m["level"] = (*req).Doc.Level
	}

	_, err := db.Collection("doc").UpdateOne(
		context.TODO(),
		filter,
		bson.M{
			"$set": m,
		},
		nil,
	)
	if err != nil {
		return err
	}

	return refreshGroupUpdateAt(goid, true)
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
	if err != nil {
		return err
	}

	return refreshGroupUpdateAt(goid, true)
}

// 根据goid删除所有印迹
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
