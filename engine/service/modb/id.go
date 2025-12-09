package modb

import (
	"context"
	"errors"
	"unicode/utf8"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func GetUOIDFromUID(uid string) (primitive.ObjectID, error) {
	if !utf8.ValidString(uid) {
		return primitive.NilObjectID, errors.New("uid contains invalid utf-8")
	}
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

// GetGIDFromGOID returns gid string for a given group object id.
func GetGIDFromGOID(goid primitive.ObjectID) (string, error) {
	identified := bson.D{{Key: "_id", Value: goid}}
	var result bson.M

	if err := db.Collection("group").FindOne(context.TODO(), identified).Decode(&result); err != nil {
		return "", err
	}

	if gid, ok := result["gid"].(string); ok {
		return gid, nil
	}
	return "", errors.New("gid not found")
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

// GetDIDsFromGOID returns all did strings for a group object id.
func GetDIDsFromGOID(goid primitive.ObjectID) ([]string, error) {
	ctx := context.TODO()
	filter := bson.D{{Key: "_goid", Value: goid}}

	cursor, err := db.Collection("doc").Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	dids := make([]string, 0)
	for cursor.Next(ctx) {
		var m bson.M
		if err := cursor.Decode(&m); err != nil {
			return nil, err
		}
		if did, ok := m["did"].(string); ok {
			dids = append(dids, did)
		}
	}

	return dids, cursor.Err()
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

// GetDIDFromDOID returns did string for a given doc object id.
func GetDIDFromDOID(doid primitive.ObjectID) (string, error) {
	filter := bson.D{{Key: "_id", Value: doid}}
	var result bson.M

	if err := db.Collection("doc").FindOne(context.TODO(), filter).Decode(&result); err != nil {
		return "", err
	}

	if did, ok := result["did"].(string); ok {
		return did, nil
	}
	return "", errors.New("did not found")
}

// GetTIDFromTOID returns tid string for a given theme object id.
func GetTIDFromTOID(toid primitive.ObjectID) (string, error) {
	identified := bson.D{{Key: "_id", Value: toid}}
	var result bson.M

	if err := db.Collection("theme").FindOne(context.TODO(), identified).Decode(&result); err != nil {
		return "", err
	}

	if tid, ok := result["tid"].(string); ok {
		return tid, nil
	}
	return "", errors.New("tid not found")
}
