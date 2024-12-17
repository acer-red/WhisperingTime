package modb

import (
	"context"
	"sys"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

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
		ID       string `json:"id"`
		UPTime   string `json:"uptime"`
		OverTime string `json:"overtime"`
	} `json:"data"`
}
type Group struct {
	Name     string `json:"name" bson:"name"`
	ID       string `json:"id" bson:"gid"`
	CRTime   string `json:"crtime" bson:"crtime"`
	UPTime   string `json:"uptime" bson:"uptime"`
	OverTime string `json:"overtime" bson:"overtime"`
}

func GetGOIDFromGID(gid string) (primitive.ObjectID, error) {

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
func GetGOIDsFromTOID(toid primitive.ObjectID) ([]primitive.ObjectID, error) {

	ctx := context.TODO()
	filter := bson.D{{Key: "_toid", Value: toid}}

	cursor, err := db.Collection("group").Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	var results []primitive.ObjectID
	for cursor.Next(ctx) {
		var b bson.M
		if err := cursor.Decode(&b); err != nil {
			return nil, err
		}
		result, _ := b["_id"].(primitive.ObjectID)
		results = append(results, result)
	}

	return results, nil
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
func GroupPost(tid string, req *RequestGroupPost) (string, error) {
	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {

		return "", err
	}
	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: req.Data.Name},
		{Key: "crtime", Value: req.Data.CRTime},
		{Key: "uptime", Value: req.Data.UPTime},
		{Key: "overtime", Value: req.Data.OverTime},
		{Key: "gid", Value: gid},
	}

	_, err = db.Collection("group").InsertOne(context.TODO(), data)

	if err != nil {

		return "", err
	}
	return gid, nil
}
func GroupPut(tid string, req *RequestGroupPut) error {

	var id string = (*req).Data.ID

	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {
		return err
	}

	filter := bson.M{
		"_toid": toid,
		"gid":   id,
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

	_, err = db.Collection("group").UpdateOne(
		context.TODO(),
		filter,
		bson.M{
			"$set": data,
		},
		nil,
	)
	return err
}
func CreateGroupDefault(tid string, crtime string) (string, error) {

	toid, err := GetThemeObjIDFromTID(tid)
	if err != nil {
		return "", err
	}
	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: "默认分组"},
		{Key: "gid", Value: gid},
		{Key: "crtime", Value: crtime},
		{Key: "default", Value: true},
	}

	_, err = db.Collection("group").InsertOne(context.TODO(), data)

	if err != nil {
		return "", err
	}
	return gid, nil
}

// 说明 根据gid删除分组
// 注意 这将删除一个分组和所有日志
func GroupDeleteFromGID(gid string) error {
	goid, err := GetGOIDFromGID(gid)
	if err != nil {
		return err
	}

	if err := DocDeleteFromGOID(goid); err != nil {
		return err
	}

	filter := bson.M{
		"_id": goid,
	}

	_, err = db.Collection("group").DeleteOne(context.TODO(), filter, nil)

	return err
}

// 说明 根据goid删除分组
// 注意 这只会删除一个分组
func GroupDeleteFromGOID(goid primitive.ObjectID) error {
	filter := bson.M{
		"_id": goid,
	}
	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)
	return err
}

// 说明 根据theme的objid 删除group
// 注意 这将删除所有group
func GroupDeleteFromTOID(toid primitive.ObjectID) error {
	data := bson.D{
		{Key: "_toid", Value: toid},
	}

	if _, err := db.Collection("group").DeleteMany(context.TODO(), data); err != nil {
		return err
	}

	return nil
}
