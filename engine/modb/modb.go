package modb

import (
	"context"
	"fmt"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

//	func isNil(id primitive.ObjectID) bool {
//		return primitive.NilObjectID == id
//	}
var mongosh *mongo.Client
var db *mongo.Database

func Init() error {
	username := "wt"
	password := "SR7Yqb959q9k38qBFDKE"
	port := "28018"
	host := "124.223.15.220"
	database := "whisperingtime"
	uri := fmt.Sprintf("mongodb://%s:%s@%s:%s/%s", username, password, host, port, database)

	clientOptions := options.Client().ApplyURI(uri)

	var err error
	mongosh, err = mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		return err
	}
	db = mongosh.Database(database)
	err = mongosh.Ping(context.TODO(), nil)
	if err != nil {
		return err
	}
	return nil
}
func Disconnect() error {
	return mongosh.Disconnect(context.TODO())
}
