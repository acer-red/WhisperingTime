package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
)

type Doc struct {
	Title   string `json:"title" bson:"title"`
	Content string `json:"content" bson:"content"`
	ID      string `json:"id" bson:"did"`
}

func DocsGet(gid string) ([]Doc, error) {
	var results []Doc
	goid, err := GetGroupObjIDFromgID(gid)
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
func DocPost(gid, content, title string) (string, error) {

	goid, err := GetGroupObjIDFromgID(gid)
	if err != nil {
		return "", err
	}

	did := sys.CreateUUID()
	data := bson.D{
		{Key: "_goid", Value: goid},
		{Key: "did", Value: did},
		{Key: "content", Value: content},
		{Key: "title", Value: title},
	}

	_, err = db.Collection("doc").InsertOne(context.TODO(), data)
	if err != nil {
		return "", err
	}
	return did, err
}
