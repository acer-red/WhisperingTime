package web

import (
	"context"
	"encoding/json"
	"fmt"
	"modb"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func ThemeGet(g *gin.Context, db *mongo.Database) {
	type response struct {
		Data string `json:"name" `
		ID   string `json:"id"`
	}

	obj_uid, err := modb.GetUserObjectUID(db, g.Query("uid"))
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Infof("获取主题 %s", obj_uid.String())

	coll := db.Collection("theme")

	filter := bson.D{
		{Key: "_uid", Value: obj_uid},
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
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgNoParam())
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
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return

		}

		data, ok := doc["data"].(string)
		if !ok {
			log.Errorf("doc.data 类型错误: %v", doc["data"])
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return

		}

		id, ok := doc["id"].(string)
		if !ok {
			log.Errorf("doc.id 类型错误: %v", doc["id"])
			g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
			return

		}
		res[i].Data = data
		res[i].ID = id
	}
	g.JSON(http.StatusOK, msgOK().setData(res))
}

func ThemePost(g *gin.Context, db *mongo.Database) {
	type request struct {
		Data struct {
			Name string `json:"name"`
			ID   string `json:"id"`
		} `json:"data" `
		UpTime string `json:"uptime"`
	}
	type response struct {
		Name string `json:"name"`
		ID   string `json:"id"`
	}

	var req request
	if err := g.ShouldBindJSON(&req); err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgNoParam())
		return
	}

	obj_uid, err := modb.GetUserObjectUID(db, g.Query("uid"))
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	themeid, err := modb.InsertTheme(db, obj_uid, &req.Data.Name)
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	log.Infof("插入主题 %s data:%s uptime:%s", obj_uid, req.Data.Name, req.UpTime)
	g.JSON(http.StatusOK, msgOK().setData(response{Name: req.Data.Name, ID: themeid}))

}
func ThemePut(g *gin.Context, db *mongo.Database) {
	type request struct {
		Data struct {
			Name string `json:"name"`
			ID   string `json:"id"`
		} `json:"data" `
		UpTime string `json:"uptime"`
	}
	type response struct {
		Name string `json:"name"`
		ID   string `json:"id"`
	}
	var req request
	if err := g.ShouldBindJSON(&req); err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgNoParam())
		return
	}
	formattedJSON, _ := json.MarshalIndent(req, "", "  ")
	fmt.Println(string(formattedJSON))

	obj_uid, err := modb.GetUserObjectUID(db, g.Query("uid"))
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	theme_obj_id, err := modb.IsExistThemeID(db, obj_uid)
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}

	err = modb.UpdateTheme(db, theme_obj_id, req.Data.Name, req.Data.ID)
	if err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	log.Infof("更新主题 %s themeid:%s uptime:%s", theme_obj_id.String(), req.Data.ID, req.UpTime)

	g.JSON(http.StatusOK, msgOK().setData(response{Name: req.Data.Name, ID: ""}))
}
func ThemeDelete(g *gin.Context, db *mongo.Database) {
	themeid := g.Query("themeid")

	if themeid == "" {
		log.Errorf(mstrNoThemeID)
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgNoParam().setMSG(mstrNoThemeID))
		return
	}

	obj_uid, err := modb.GetUserObjectUID(db, g.Query("uid"))
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
		return
	}
	coll := db.Collection("theme")
	result, err := coll.UpdateOne(context.TODO(),
		bson.M{"_uid": obj_uid},
		bson.M{"$pull": bson.M{"theme": bson.M{"id": themeid}}},
	)
	if err != nil {
		g.AbortWithStatusJSON(http.StatusInternalServerError, msgNoParam().setMSG(mstrNoThemeID))
		return
	}
	log.Infof("删除主题数%d %s themeid:%s", result.ModifiedCount, obj_uid.String(), themeid)
	g.JSON(http.StatusOK, msgOK())
}
