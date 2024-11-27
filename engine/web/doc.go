package web

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func DocPost(g *gin.Context) {
	g.Query("uid")
	type request struct {
		Data    string `json:"data"`
		ThemeID string `json:"themeid"`
		Group   string `json:"group"`
		Title   string `json:"title"`
		UpTime  string `json:"uptime"`
	}
	var req request
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
		return
	}
	// uid := g.Query("uid")
	// tid := req.ThemeID
	// title := req.Title
	// group := req.Group

	// toid, err := modb.InsertGroup( uid, tid, group)
	// if err != nil {
	// 	log.Error(err)
	// 	g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
	// 	return
	// }

	// 根据themeid和userid创建group，和doc

	// result, err := db.Collection("doc").InsertOne(context.TODO(), ash)
	// if err != nil {
	// 	log.Fatal(err)
	// }

	// fmt.Println("插入文档的 ID:", result.InsertedID)

	g.String(http.StatusOK, "")
}
