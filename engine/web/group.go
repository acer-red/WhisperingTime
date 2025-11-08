package web

import (
	"strings"

	"github.com/tengfei-xy/whisperingtime/engine/modb"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func RouteGroup(g *gin.Engine) {
	a := g.Group("/groups/:tid")
	{
		a.Use(getTid())
		a.GET("", GroupsGet)
	}

	b := g.Group("/group/:tid")
	{
		b.Use(getTid())
		b.POST("", GroupPost)
	}

	c := g.Group("/group/:tid/:gid")
	{
		c.Use(getTidAndGid())
		c.GET("", GroupGet)
		c.PUT("", GroupPutID)
		c.DELETE("", GroupIDDelete)
	}
	d := g.Group("/group/:tid/:gid/export_config")
	{
		d.Use(getTidAndGid())
		d.POST("", GroupPostExportConfig)
	}

	e := g.Group("/group/:tid/from_config")
	{
		e.Use(getTid())
		e.POST("", GroupPostImportConfig)
	}

}

func GroupsGet(g *gin.Context) {
	log.Info("获取所有分组")

	toid := g.MustGet("toid").(primitive.ObjectID)

	response, err := modb.GroupsGet(toid)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, response)
}
func GroupGet(g *gin.Context) {

	has_doc := g.Query("doc")
	has_detail := g.Query("detail")

	if has_doc == "1" && has_detail == "1" {
		groupGetAndDocDetail(g)
		return
	}
	groupGetNoDetail(g)

}
func GroupPost(g *gin.Context) {
	log.Infof("获取主题")

	toid := g.MustGet("toid").(primitive.ObjectID)

	// 响应必须返回ID
	type response struct {
		ID string `json:"id"`
	}

	var req modb.RequestGroupPost
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	id, err := modb.GroupPost(toid, &req)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, response{ID: id})
}
func GroupPutID(g *gin.Context) {
	log.Infof("修改分组")

	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)

	var req modb.RequestGroupPut

	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	if err := modb.GroupPut(toid, goid, &req); err != nil {
		internalServerError(g)
		return
	}

	ok(g)
}
func GroupIDDelete(g *gin.Context) {
	log.Infof("删除分组")

	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)

	err := modb.GroupDeleteOne(toid, goid)
	if err != nil {
		internalServerError(g)
		return
	}

	ok(g)
}
func groupGetAndDocDetail(g *gin.Context) {
	log.Infof("获取分组包含数据")
	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)

	response, err := modb.GroupGetAndDocDetail(toid, goid)
	if err != nil {
		internalServerError(g)
		return
	}

	okData(g, response)
}
func groupGetNoDetail(g *gin.Context) {

	log.Infof("获取分组")
	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)

	response, err := modb.GroupGet(toid, goid)
	if err != nil {
		internalServerError(g)
		return
	}

	okData(g, response)
}
func GroupPostExportConfig(g *gin.Context) {
	log.Info("导出分组配置")
	uoid := g.MustGet("uoid").(primitive.ObjectID)
	toid := g.MustGet("toid").(primitive.ObjectID)
	goid := g.MustGet("goid").(primitive.ObjectID)
	taskID, err := modb.GroupExportConfig(uoid, toid, goid)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, map[string]interface{}{
		"taskId": taskID,
	})
}

func GroupPostImportConfig(g *gin.Context) {
	log.Info("导入分组配置")
	uoid := g.MustGet("uoid").(primitive.ObjectID)
	toid := g.MustGet("toid").(primitive.ObjectID)

	// 接收上传的文件
	file, err := g.FormFile("file")
	if err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	// 验证文件扩展名
	if !strings.HasSuffix(file.Filename, ".zip") {
		log.Error("文件格式错误，不是 .zip 文件")
		badRequestMsg(g, "文件格式错误，请上传 .zip 文件")
		return
	}

	err = modb.GroupImportConfig(uoid, toid, file)
	if err != nil {
		log.Error(err)
		badRequestMsg(g, err.Error())
		return
	}

	ok(g)
}
