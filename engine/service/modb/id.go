package modb

import (
	"context"
	"errors"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func GetUOIDFromUID(uid string) (primitive.ObjectID, error) {
	var result bson.M
	ctx := context.TODO()
	filter := bson.D{{Key: "uid", Value: uid}}

	if err := db.Collection("user").FindOne(ctx, filter).Decode(&result); err != nil {
		if err == mongo.ErrNoDocuments {
			res, err := db.Collection("user").InsertOne(ctx, filter)
			if err != nil {
				log.Error(err)
				return primitive.NilObjectID, err
			}
			return res.InsertedID.(primitive.ObjectID), nil
		}
		log.Error(err)
		return primitive.NilObjectID, err
	}

	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, errors.New("无法获取id")
	}
	return id, nil
}

// 输入tid，返回toid
func GetTOIDFromTID(tid string) (primitive.ObjectID, error) {

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
		var m bson.M
		if err := cursor.Decode(&m); err != nil {
			return nil, err
		}
		result, _ := m["_id"].(primitive.ObjectID)
		results = append(results, result)
	}

	return results, nil
}
func GetDOIDFromGOIDAndDID(goid primitive.ObjectID, did string) (primitive.ObjectID, error) {

	filter := bson.D{{Key: "_goid", Value: goid}, {Key: "did", Value: did}}
	var result bson.M

	if err := db.Collection("doc").FindOne(context.TODO(), filter).Decode(&result); err != nil {
		return primitive.NilObjectID, err
	}

	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, nil
	}

	return id, nil
}
