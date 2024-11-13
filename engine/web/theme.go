package web

import (
	"context"
	"fmt"
	"modb"
	"net/http"
	"sys"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func THEMEGet(g *gin.Context, db *mongo.Database) {
	type response struct {
		Data string `json:"name" `
		ID   string `json:"id"`
	}
	uid := g.Query("uid")

	id, err := modb.GetUserObjectID(db, uid)
	if err != nil {
		g.String(http.StatusInternalServerError, "内部系统错误")
		return
	}
	log.Infof("id=%s uid=%s", id.String(), uid)

	coll := db.Collection("theme")

	filter := bson.D{
		{Key: "_uid", Value: id},
	}

	var result bson.M

	err = coll.FindOne(context.TODO(), filter).Decode(&result)
	res := make([]response, 1)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			g.JSON(http.StatusOK, msgOK().setData(res))
			return
		}
		log.Error(err)
		g.JSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	itemArray, ok := result["theme"].(bson.A) //  类型断言为数组
	if !ok {
		log.Errorf("theme 字段类型错误: %v", result["theme"])
		return
	}
	res = make([]response, len(itemArray))
	for i, item := range itemArray {
		doc, ok := item.(bson.M) //  类型断言为 bson.M
		if !ok {
			log.Errorf("doc 元素类型错误: %v", item)
			g.JSON(http.StatusInternalServerError, msgInternalServer())
			return

		}

		data, ok := doc["data"].(string)
		if !ok {
			log.Errorf("doc.data 类型错误: %v", doc["data"])
			g.JSON(http.StatusInternalServerError, msgInternalServer())
			return

		}

		id, ok := doc["id"].(string)
		if !ok {
			log.Errorf("doc.id 类型错误: %v", doc["id"])
			g.JSON(http.StatusInternalServerError, msgInternalServer())
			return

		}
		res[i].Data = data
		res[i].ID = id
	}
	g.JSON(http.StatusOK, msgOK().setData(res))
}

type req struct {
	Data   string `json:"data" `
	UpTime string `json:"uptime"`
}

func THEMEPost(g *gin.Context, db *mongo.Database) {

	type response struct {
		ThemeID string `json:"themeid"`
	}

	uid := g.Query("uid")

	var req req
	if err := g.ShouldBindJSON(&req); err != nil {
		log.Debug("请求体错误")
		g.String(http.StatusBadRequest, "请求体错误")
		return
	}
	log.Infof("theme uid:%s data:%s uptime:%s", uid, req.Data, req.UpTime)

	id, err := modb.GetUserObjectID(db, uid)
	if err != nil {
		g.String(http.StatusInternalServerError, "内部系统错误")
		return
	}

	// theme := bson.D{
	// 	{Key: "_uid", Value: id},
	// 	{Key: "theme", Value: bson.D{
	// 		{Key: "$elemMatch", Value: bson.D{
	// 			{Key: "data", Value: req.Data},
	// 		}},
	// 	}},
	// }
	InternalServer := fmt.Errorf("内部系统错误")

	// find := bson.D{
	// 	{Key: "_uid", Value: id},
	// 	{Key: "theme", Value: bson.A{
	// 		bson.D{
	// 			{Key: "id", Value: themeid},
	// 		},
	// 	}},
	// }

	// _, err = coll.CountDocuments(context.TODO(), bson.D{
	// 	{Key: "_uid", Value: id}})
	// if err != nil {
	// 	log.Error(InternalServer)
	// 	g.AbortWithError(http.StatusInternalServerError, InternalServer)
	// }
	themeid := sys.CreateUUID()
	// themeid := "233"
	theme := bson.D{
		{Key: "_uid", Value: id},
		{Key: "theme", Value: bson.A{
			bson.D{
				{Key: "data", Value: req.Data},
				{Key: "id", Value: themeid},
			},
		}},
	}
	coll := db.Collection("theme")
	_, err = coll.InsertOne(context.TODO(), theme)
	if err != nil {
		log.Error(InternalServer)
		g.AbortWithError(http.StatusInternalServerError, InternalServer)
	}
	log.Infof("插入主题成功 uid:%s themeid:%s", uid, themeid)

	g.JSON(http.StatusOK, msgOK().setData(response{ThemeID: themeid}))

	// coll = db.Collection("theme")

	// // 查询单个文档
	// var exist bool = false
	// var result bson.M
	// if err := coll.FindOne(context.TODO(), filter).Decode(&result); err != nil {
	// 	if err != mongo.ErrNoDocuments {
	// 		log.Error(err)
	// 		g.String(http.StatusInternalServerError, "内部系统错误")
	// 		return
	// 	}
	// 	exist = false
	// }
	// if exist {
	// 	log.Debugf("主题已存在")
	// 	return
	// }

	// id := uid.New().String()
	// doc := bson.D{
	// 	{Key: "uid", Value: uid},
	// 	{Key: "theme", Value: bson.D{
	// 		{Key: "data", Value: req.Data},
	// 		{Key: "id", Value: id},
	// 	}},
	// }
	// if _, err := coll.InsertOne(context.TODO(), doc); err != nil {
	// 	log.Error(err)
	// 	g.String(http.StatusInternalServerError, "内部系统错误")
	// }
	// log.Debugf("创建主题 %s", id)

	// col := db.Collection("theme")

}
