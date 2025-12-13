package modb

import (
	"context"
	"errors"
	"time"

	"github.com/acer-red/whisperingtime/engine/util"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

const scaleTemplatesCollection = "scale_templates"

type ScaleTemplateRecord struct {
	ID                string    `bson:"id"`
	EncryptedMetadata []byte    `bson:"encrypted_metadata"`
	CreateAt          time.Time `bson:"createAt"`
}

func ScaleTemplateCreate(uoid primitive.ObjectID, encryptedMetadata []byte) (string, error) {
	if uoid == primitive.NilObjectID {
		return "", errors.New("invalid uoid")
	}
	if len(encryptedMetadata) == 0 {
		return "", errors.New("encrypted_metadata is empty")
	}

	id := util.CreateUUID()
	doc := bson.D{
		{Key: "_uid", Value: uoid},
		{Key: "id", Value: id},
		{Key: "encrypted_metadata", Value: encryptedMetadata},
		{Key: "createAt", Value: time.Now()},
	}
	_, err := db.Collection(scaleTemplatesCollection).InsertOne(context.TODO(), doc)
	if err != nil {
		return "", err
	}
	return id, nil
}

func ScaleTemplatesList(uoid primitive.ObjectID) ([]ScaleTemplateRecord, error) {
	if uoid == primitive.NilObjectID {
		return nil, errors.New("invalid uoid")
	}

	filter := bson.D{{Key: "_uid", Value: uoid}}
	findOpts := options.Find().SetSort(bson.D{{Key: "createAt", Value: -1}})
	cursor, err := db.Collection(scaleTemplatesCollection).Find(context.TODO(), filter, findOpts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(context.TODO())

	results := make([]ScaleTemplateRecord, 0)
	for cursor.Next(context.TODO()) {
		var r ScaleTemplateRecord
		if err := cursor.Decode(&r); err != nil {
			return nil, err
		}
		results = append(results, r)
	}
	return results, cursor.Err()
}

func ScaleTemplateUpdate(uoid primitive.ObjectID, id string, encryptedMetadata []byte) error {
	if uoid == primitive.NilObjectID {
		return errors.New("invalid uoid")
	}
	if id == "" {
		return errors.New("id is empty")
	}
	if len(encryptedMetadata) == 0 {
		return errors.New("encrypted_metadata is empty")
	}

	filter := bson.D{{Key: "_uid", Value: uoid}, {Key: "id", Value: id}}
	update := bson.D{{Key: "$set", Value: bson.D{{Key: "encrypted_metadata", Value: encryptedMetadata}}}}
	res, err := db.Collection(scaleTemplatesCollection).UpdateOne(context.TODO(), filter, update)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return errors.New("template not found")
	}
	return nil
}

func ScaleTemplateDelete(uoid primitive.ObjectID, id string) error {
	if uoid == primitive.NilObjectID {
		return errors.New("invalid uoid")
	}
	if id == "" {
		return errors.New("id is empty")
	}

	filter := bson.D{{Key: "_uid", Value: uoid}, {Key: "id", Value: id}}
	res, err := db.Collection(scaleTemplatesCollection).DeleteOne(context.TODO(), filter)
	if err != nil {
		return err
	}
	if res.DeletedCount == 0 {
		return errors.New("template not found")
	}
	return nil
}
