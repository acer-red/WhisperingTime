package modb

import (
	"go.mongodb.org/mongo-driver/mongo"
)

func InsertGroup(db *mongo.Database, uid, tid, group string) (string, error) {

	// GetThemeObjID(db, uid)
	// themeid := sys.CreateUUID()
	// theme := bson.D{
	// 	{Key: "_uid", Value: uoid},
	// 	{Key: "theme", Value: bson.A{
	// 		bson.D{
	// 			{Key: "data", Value: data},
	// 			{Key: "id", Value: themeid},
	// 		},
	// 	}},
	// }
	// coll := db.Collection("theme")
	// _, err = coll.InsertOne(context.TODO(), theme)
	return "", nil
}
