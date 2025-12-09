package web

import (
	"net/url"
	"os"
	"path/filepath"

	"github.com/acer-red/whisperingtime/engine/service/modb"
	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func RouteBGJob(g *gin.Engine) {
	// 获取所有后台任务
	a := g.Group("/bgjobs")
	{
		a.GET("", BGJobsGet)
	}

	// 获取单个后台任务
	b := g.Group("/bgjob/:bgjid")
	{
		b.Use(getBGJid())
		b.GET("", BGJobGet)
		b.GET("/download", BGJobDownload)
		b.DELETE("", BGJobDelete)
	}
}

// BGJobsGet 获取用户所有后台任务
func BGJobsGet(g *gin.Context) {
	log.Info("获取所有后台任务")

	uoid := g.MustGet("uoid").(primitive.ObjectID)

	jobs, err := modb.BGJobsGet(uoid)
	if err != nil {
		internalServerError(g)
		return
	}

	okData(g, jobs)
}

// BGJobGet 获取单个后台任务详情
func BGJobGet(g *gin.Context) {
	log.Info("获取后台任务详情")

	uoid := g.MustGet("uoid").(primitive.ObjectID)
	bgjoid := g.MustGet("bgjoid").(primitive.ObjectID)

	job, err := modb.BGJobGet(uoid, bgjoid)
	if err != nil {
		internalServerError(g)
		return
	}

	okData(g, job)
}

// BGJobDownload 下载后台任务生成的文件
func BGJobDownload(g *gin.Context) {
	log.Info("下载后台任务文件")

	uoid := g.MustGet("uoid").(primitive.ObjectID)
	bgjoid := g.MustGet("bgjoid").(primitive.ObjectID)

	job, err := modb.BGJobGet(uoid, bgjoid)
	if err != nil {
		internalServerError(g)
		return
	}

	// 检查任务状态
	if job.Status != modb.JobStatusCompleted {
		badRequestMsg(g, "任务未完成")
		return
	}

	// 从 Payload 中获取文件路径
	var filePath string
	if job.Payload != nil {
		if filename, ok := job.Payload["filename"].(string); ok {
			filePath = filename
		}
	}

	if filePath == "" {
		l := "任务未生成文件"
		log.Error(l)
		badRequestMsg(g, l)
		return
	} else {
		log.Infof("读取文件:%s", filePath)
	}

	// 检查文件是否存在
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		log.Error("文件不存在")
		notFound(g)
		return
	}

	// 设置响应头并发送文件
	fileName := filepath.Base(filePath)
	// 对文件名进行 URL 编码以支持中文和特殊字符
	encodedFileName := url.QueryEscape(fileName)
	g.Header("Content-Description", "File Transfer")
	g.Header("Content-Transfer-Encoding", "binary")
	// 使用 RFC 2231 编码格式，同时提供 ASCII 备用文件名
	g.Header("Content-Disposition", "attachment; filename=\""+fileName+"\"; filename*=UTF-8''"+encodedFileName)
	g.Header("Content-Type", "application/octet-stream")
	g.File(filePath)
}

// BGJobDelete 删除后台任务
func BGJobDelete(g *gin.Context) {
	log.Info("删除后台任务")

	uoid := g.MustGet("uoid").(primitive.ObjectID)
	bgjoid := g.MustGet("bgjoid").(primitive.ObjectID)

	err := modb.BGJobDelete(uoid, bgjoid)
	if err != nil {
		internalServerError(g)
		return
	}

	ok(g)
}
