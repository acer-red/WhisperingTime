package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Group struct {
	Name     string `json:"name" bson:"name"`
	ID       string `json:"id" bson:"gid"`
	CRTime   string `json:"crtime" bson:"crtime"`
	UPTime   string `json:"uptime" bson:"uptime"`
	OverTime string `json:"overtime" bson:"overtime"`
}

type RequestGroupPost struct {
	Data struct {
		Name     string `json:"name"`
		CRTime   string `json:"crtime"`
		UPTime   string `json:"uptime"`
		OverTime string `json:"overtime"`
	} `json:"data"`
}
type RequestGroupPut struct {
	Data struct {
		Name     string `json:"name"`
		UPTime   string `json:"uptime"`
		OverTime string `json:"overtime"`
	} `json:"data"`
}

func GroupsGet(toid primitive.ObjectID) ([]Group, error) {
	var results []Group

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
func GroupGet(toid primitive.ObjectID, goid primitive.ObjectID) (Group, error) {

	var response Group
	var results bson.M

	filter := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "_id", Value: goid},
	}

	err := db.Collection("group").FindOne(context.TODO(), filter).Decode(&results)
	if err != nil {
		return Group{}, err
	}
	response.ID = results["gid"].(string)
	response.Name = results["name"].(string)
	response.CRTime = results["crtime"].(string)
	response.UPTime = results["uptime"].(string)
	response.OverTime = results["overtime"].(string)

	return response, nil
}
func GroupPost(toid primitive.ObjectID, req *RequestGroupPost) (string, error) {

	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: req.Data.Name},
		{Key: "crtime", Value: req.Data.CRTime},
		{Key: "uptime", Value: req.Data.UPTime},
		{Key: "overtime", Value: req.Data.OverTime},
		{Key: "gid", Value: gid},
	}

	_, err := db.Collection("group").InsertOne(context.TODO(), data)
	if err != nil {
		return "", err
	}

	return gid, nil
}
func GroupPut(toid primitive.ObjectID, goid primitive.ObjectID, req *RequestGroupPut) error {

	filter := bson.M{
		"_toid": toid,
		"_id":   goid,
	}

	data := bson.M{}

	if (*req).Data.Name != "" {
		data["name"] = (*req).Data.Name
	}

	if (*req).Data.UPTime != "" {
		data["uptime"] = (*req).Data.UPTime
	}

	if (*req).Data.OverTime != "" {
		data["overtime"] = (*req).Data.OverTime
	}

	_, err := db.Collection("group").UpdateOne(
		context.TODO(),
		filter,
		bson.M{
			"$set": data,
		},
		nil,
	)
	return err
}
func GroupCreateDefault(toid primitive.ObjectID, gd RequestThemePostDefaultGroup) (string, error) {

	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: gd.Name},
		{Key: "gid", Value: gid},
		{Key: "crtime", Value: gd.CRTime},
		{Key: "overtime", Value: gd.Overtime},
		{Key: "default", Value: true},
	}

	_, err := db.Collection("group").InsertOne(context.TODO(), data)

	if err != nil {
		return "", err
	}
	return gid, nil
}

// 说明 删除一个分组和所有日志
func GroupDeleteOne(toid primitive.ObjectID, goid primitive.ObjectID) error {
	filter := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "_id", Value: goid},
	}

	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)

	return err
}

// 说明 根据goid删除一个分组
func GroupDeleteFromGOID(goid primitive.ObjectID) error {
	filter := bson.M{
		"_id": goid,
	}
	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)
	return err
}
