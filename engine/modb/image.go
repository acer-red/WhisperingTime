package modb

import (
	"context"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func ImageGet(name string) ([]byte, error) {
	log.Infof("图片提取")
	var result struct {
		Image primitive.Binary `bson:"data"`
	}

	filter := bson.D{{Key: "name", Value: name}}

	err := db.Collection("image").FindOne(context.TODO(), filter).Decode(&result)
	if err != nil {
		return nil, err
	}
	return result.Image.Data, nil
}
func ImageCreate(name string, data []byte) (any, error) {
	log.Infof("图片创建")
	type response struct {
		Name string `json:"name"`
	}
	identified := bson.D{{Key: "name", Value: name}, {Key: "data", Value: data}}
	_, err := db.Collection("image").InsertOne(context.TODO(), identified)
	if err != nil {
		return "", err
	}

	// 获取 GridFS
	// db := session.DB("your_database_name")
	// gridFS := db.GridFS("fs")

	// // 创建 GridFS 文件
	// file, err := gridFS.Create(imageUpload.Filename)
	// if err != nil {
	//   c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create GridFS file"})
	//   return
	// }

	return response{Name: name}, nil
}
