package modb

import (
	"context"
	"strconv"
	"time"

	"github.com/tengfei-xy/whisperingtime/engine/sys"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"

	m "github.com/tengfei-xy/whisperingtime/engine/model"
)

type RequestDocPost struct {
	Data struct {
		Content  m.DocContent `json:"content"`
		CreateAt string       `json:"createAt"`
		Config   *m.DocConfig `json:"config"`
	} `json:"data"`
}

type RequestDocPut struct {
	Doc struct {
		Content  *m.DocContent `json:"content,omitempty" bson:"content"`
		CreateAt *string       `json:"createAt,omitempty"`
		UpdateAt *string       `json:"updateAt,omitempty"`
		Config   *m.DocConfig  `json:"config,omitempty" bson:"config"`
		ID       *string       `json:"id" bson:"did"`
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

		contentM := doc["content"].(bson.M)
		levelBytes := extractLevelBytes(contentM, doc)
		configM, _ := doc["config"].(bson.M)
		cfg := &m.DocConfig{}
		if configM != nil {
			if v, ok := configM["is_show_tool"].(bool); ok {
				cfg.IsShowTool = v
			}
		}
		results = append(results, m.Doc{
			Content: m.DocContent{
				Title: contentM["title"].(primitive.Binary).Data,
				Rich:  contentM["rich"].(primitive.Binary).Data,
				Level: levelBytes,
			},
			CreateAt: doc["createAt"].(primitive.DateTime).Time(),
			UpdateAt: doc["updateAt"].(primitive.DateTime).Time(),
			Config:   cfg,
			ID:       doc["did"].(string),
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
		{Key: "content", Value: (*req).Data.Content},
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
		if (*req).Doc.Content.Title != nil {
			m["content.title"] = (*req).Doc.Content.Title
		}
		if (*req).Doc.Content.Rich != nil {
			m["content.rich"] = (*req).Doc.Content.Rich
		}
		if (*req).Doc.Content.Level != nil {
			m["content.level"] = (*req).Doc.Content.Level
		}
	}

	if (*req).Doc.CreateAt != nil {
		m["createAt"] = sys.StringtoTime(*(*req).Doc.CreateAt)
	}

	if (*req).Doc.UpdateAt != nil {
		m["updateAt"] = sys.StringtoTime(*(*req).Doc.UpdateAt)
	}

	if (*req).Doc.Config != nil {
		m["config"] = bson.M{
			"is_show_tool": (*req).Doc.Config.IsShowTool,
		}
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

func extractLevelBytes(content bson.M, doc bson.M) []byte {
	if raw, ok := content["level"]; ok {
		switch v := raw.(type) {
		case primitive.Binary:
			return v.Data
		case []byte:
			return v
		}
	}

	if raw, ok := doc["level"]; ok {
		switch v := raw.(type) {
		case int32:
			return []byte(strconv.Itoa(int(v)))
		case int64:
			return []byte(strconv.FormatInt(v, 10))
		case float64:
			return []byte(strconv.Itoa(int(v)))
		}
	}

	return nil
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
