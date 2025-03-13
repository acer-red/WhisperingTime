package modb

import (
	"context"
	"sys"
	"time"

	"github.com/tengfei-xy/go-log"
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
	Level     int32   `json:"level" bson:"level"`
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
		Level     int32   `json:"level"`
		CRTime    string  `json:"crtime"`
		Config    *config `json:"config"`
	} `json:"data"`
}

type RequestDocPut struct {
	Doc struct {
		Title     *string `json:"title,omitempty" bson:"title"`
		Content   *string `json:"content,omitempty" bson:"content"`
		PlainText *string `json:"plain_text,omitempty" bson:"plain_text"`
		Level     *int32  `json:"level,omitempty" bson:"level"`
		CRTime    *string `json:"crtime,omitempty"`
		UPTime    *string `json:"uptime,omitempty"`
		Config    *config `json:"config,omitempty" bson:"config"`
		ID        *string `json:"id" bson:"did"`
	} `json:"data"`
}
type DocFilter struct {
	Year  int `json:"year"`
	Month int `json:"month"`
}

// func DocsGet(goid primitive.ObjectID,DocFilter f) ([]Doc, error) {
// 	var results []Doc

// 	filter := bson.D{
// 		{Key: "_goid", Value: goid},
// 	}

// 	cursor, err := db.Collection("doc").Find(context.TODO(), filter)
// 	if err != nil {
// 		log.Error(err)
// 		return nil, err
// 	}

// 	for cursor.Next(context.TODO()) {
// 		var m bson.M
// 		err := cursor.Decode(&m)
// 		if err != nil {
// 			log.Error(err)
// 			return nil, err
// 		}
// 		results = append(results, Doc{
// 			Title:     m["title"].(string),
// 			Content:   m["content"].(string),
// 			PlainText: m["plain_text"].(string),
// 			Level:     m["level"].(int32),
// 			CRTime:    m["crtime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
// 			UPTime:    m["uptime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
// 			Config: &config{
// 				IsShowTool: m["config"].(bson.M)["is_show_tool"].(bool),
// 			},
// 			ID: m["did"].(string),
// 		})
// 	}

// 	if err := cursor.Err(); err != nil {
// 		log.Error(err)
// 		return nil, err
// 	}

//		return results, nil
//	}
func DocsGet(goid primitive.ObjectID, f DocFilter) ([]Doc, error) {

	var results []Doc

	filter := bson.D{
		{Key: "_goid", Value: goid},
	}
	if f.Year != 0 && f.Month != 0 {
		filter = append(filter, bson.E{Key: "crtime", Value: bson.M{
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
		var m bson.M
		err := cursor.Decode(&m)
		if err != nil {
			log.Error(err)
			return nil, err
		}
		results = append(results, Doc{
			Title:     m["title"].(string),
			Content:   m["content"].(string),
			PlainText: m["plain_text"].(string),
			Level:     m["level"].(int32),
			CRTime:    m["crtime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
			UPTime:    m["uptime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
			Config: &config{
				IsShowTool: m["config"].(bson.M)["is_show_tool"].(bool),
			},
			ID: m["did"].(string),
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
		{Key: "crtime", Value: sys.StringtoTime((*req).Data.CRTime)},
		{Key: "uptime", Value: sys.StringtoTime((*req).Data.CRTime)},
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

	m := bson.M{}

	if (*req).Doc.Content != nil {
		m["content"] = (*req).Doc.Content
		m["plain_text"] = (*req).Doc.PlainText
	}

	if (*req).Doc.Title != nil {
		m["title"] = (*req).Doc.Title
	}

	if (*req).Doc.CRTime != nil {
		m["crtime"] = sys.StringtoTime(*(*req).Doc.CRTime)
	}

	if (*req).Doc.UPTime != nil {
		m["uptime"] = sys.StringtoTime(*(*req).Doc.UPTime)
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
