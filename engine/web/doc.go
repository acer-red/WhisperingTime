package web

import (
	"context"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

func DOCPost(g *gin.Context, db *mongo.Database) {
	uid := g.Query("uid")
	if uid == "" {
		log.Debug("缺少uid")
		g.String(http.StatusBadRequest, "缺少uid")
		return
	}
	type reqj struct {
		Data  string
		Theme struct {
			data string
			id   string
		}
		Event struct {
			data string
			id   string
		}
		Title struct {
			data string
			id   string
		}
		Doc struct {
			data       string
			id         string
			UpadteTime int64
		}
	}
	var req reqj
	err := g.ShouldBindBodyWithJSON(req)
	if err != nil {
		log.Debug("请求体错误")
		g.String(http.StatusBadRequest, "请求体错误")
		return
	}
	col := db.Collection("doc")
	// 用于创建 BSON 文档
	ash := bson.D{{"data", req.Data}, {"data", req.Data}}

	// 插入单个文档
	result, err := col.InsertOne(context.TODO(), ash)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("插入文档的 ID:", result.InsertedID)

	g.String(http.StatusOK, "")
}
