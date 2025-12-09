package modb

import (
	"context"
	"strings"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var mongosh *mongo.Client
var db *mongo.Database
var indexEndpoint string

func Init(uri string) error {
	clientOptions := options.Client().ApplyURI(uri)

	var err error
	mongosh, err = mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		return err
	}
	s := strings.Split(uri, "/")
	db = mongosh.Database(s[len(s)-1])
	err = mongosh.Ping(context.TODO(), nil)
	if err != nil {
		return err
	}
	return nil
}

// SetIndexEndpoint configures the index service base URL for API verification.
func SetIndexEndpoint(url string) {
	indexEndpoint = strings.TrimRight(url, "/")
}
func Disconnect() error {
	return mongosh.Disconnect(context.TODO())
}
