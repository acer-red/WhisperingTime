package web

import (
	"fmt"
	"io"
	"modb"
	"strings"
	"sys"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func DocRoute(g *gin.Engine) {
	a := g.Group("/docs/:gid")
	{
		a.Use(getGid())
		a.GET("", DocsGet)
	}

	b := g.Group("/doc/:gid")
	{
		b.Use(getGid())
		b.POST("", DocPost)
	}

	c := g.Group("/doc/:gid/:did")
	{
		c.Use(getGidAndDid())
		c.PUT("", DocIDPut)
		c.DELETE("", DocIDDelete)
	}
	d := g.Group("/doc/image/:file")
	{
		d.GET("", DocImageGet)
		d.DELETE("", DocImageDelete)
	}
	e := g.Group("/doc/image")
	{
		e.POST("", DocImagePost)
	}
}

func DocsGet(g *gin.Context) {
	year_str := query(g, "year")
	month_str := query(g, "month")

	if year_str == "" && month_str == "" {
		docsGetNoDate(g)
		return
	}
	docsGetWithDate(g, year_str, month_str)

}
func DocPost(g *gin.Context) {

	type response struct {
		ID string `json:"id"`
	}
	log.Info("创建印迹")

	goid := g.MustGet("goid").(primitive.ObjectID)
	var req modb.RequestDocPost

	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		badRequest(g)
		return
	}

	did, err := modb.DocPost(goid, &req)
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	okData(g, response{ID: did})
}
func DocIDPut(g *gin.Context) {
	log.Info("更新印迹")
	goid := g.MustGet("goid").(primitive.ObjectID)
	doid := g.MustGet("doid").(primitive.ObjectID)

	var req modb.RequestDocPut
	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	if err := modb.DocPut(goid, doid, &req); err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	ok(g)
}
func DocIDDelete(g *gin.Context) {

	log.Info("删除印迹")
	goid := g.MustGet("goid").(primitive.ObjectID)
	doid := g.MustGet("doid").(primitive.ObjectID)

	if err := modb.DocDelete(goid, doid); err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	ok(g)
}

func docsGetNoDate(g *gin.Context) {
	log.Info("获取所有印迹")
	goid := g.MustGet("goid").(primitive.ObjectID)

	ret, err := modb.DocsGet(goid)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, ret)
}

func docsGetWithDate(g *gin.Context, year, month string) {
	log.Info("获取所有印迹(含时间)")

	goid := g.MustGet("goid").(primitive.ObjectID)

	yyyy := sys.YYYYToInt(year)
	mm := sys.MMToInt(month)
	ret, err := modb.DocsGetWithDate(goid, yyyy, mm)
	if err != nil {
		internalServerError(g)
		return
	}
	okData(g, ret)
}

func DocImageGet(g *gin.Context) {
	log.Debugf("印迹图片提取")
	name := g.Param("file")
	res, err := modb.ImageGet(name)

	if err == sys.ERR_NO_FOUND {
		notFound(g)
		return
	}
	if err != nil {
		internalServerError(g)
		return
	}

	okImage(g, res)
}
func DocImagePost(g *gin.Context) {
	log.Infof("印迹图片创建")
	type request struct {
		Name string `json:"name"`
	}
	contentType := g.Request.Header.Get("Content-Type")
	contentType = strings.ToLower(contentType)

	if contentType != "image/png" && contentType != "image/jpeg" {
		badRequest(g)
		return
	}
	name := fmt.Sprintf("%s.%s", sys.CreateUUID(), contentType[6:])

	body, err := io.ReadAll(g.Request.Body)
	if err != nil {
		badRequest(g)
		return
	}
	if len(body) == 0 {
		badRequest(g)
		return
	}

	if err := modb.ImageCreate(name, body); err != nil {
		internalServerError(g)
		return
	}
	okData(g, request{
		Name: name,
	})
}
func DocImageDelete(g *gin.Context) {
	log.Infof("印迹图片删除")
	name := g.Param("file")

	err := modb.ImageDelete(name)
	if err == sys.ERR_NO_FOUND {
		notFound(g)
		return
	}
	if err != nil {
		internalServerError(g)
		return
	}
	ok(g)
}
