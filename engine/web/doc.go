package web

import (
	"net/http"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/mongo"
)

func DocPost(g *gin.Context, db *mongo.Database) {
	g.Query("uid")
	type request struct {
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
	var req request
	if err := g.ShouldBindBodyWithJSON(req); err != nil {
		log.Error(err)
		g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
		return
	}
	// col := db.Collection("doc")
	// 用于创建 BSON 文档
	// ash := bson.D{{"data", req.Data}, {"data", req.Data}}

	// 插入单个文档
	// result, err := col.InsertOne(context.TODO(), ash)
	// if err != nil {
	// 	log.Fatal(err)
	// }

	// fmt.Println("插入文档的 ID:", result.InsertedID)

	g.String(http.StatusOK, "")
}
