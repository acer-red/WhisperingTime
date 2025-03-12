package web

import (
	"fmt"
	"io"
	"modb"
	"path/filepath"
	"strconv"
	"sys"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func FeedbackRoute(g *gin.Engine) {
	a := g.Group("/feedback")
	{
		a.POST("", fbPost)
	}

	b := g.Group("/feedbacks")
	{
		b.GET("", fbsGet)
	}

	// c := g.Group("/feedback/:fbid")
	// {
	// 	c.Use(getGidAndDid())
	// 	c.GET("", fbGet)
	// 	c.PUT("", fbPut)
	// }
}
func fbPost(g *gin.Context) {
	log.Info("创建反馈")

	type response struct {
		ID string `json:"id"`
	}
	res := response{
		ID: sys.CreateUUID(),
	}

	var req modb.RequestFeedbackPost
	req.FBID = res.ID
	if err := g.ShouldBind(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	form, err := g.MultipartForm()
	if err != nil {
		log.Error(err)
		badRequest(g)
		return
	}

	req.FbType = atoi(form.Value["fb_type"][0])
	req.Title = form.Value["title"][0]
	req.Content = form.Value["content"][0]

	deviceFiles := form.File["device_file"]
	if len(deviceFiles) > 0 {
		file, err := deviceFiles[0].Open()
		if err != nil {
			log.Error(err)
			badRequest(g)
			return
		}
		defer file.Close()
		req.DeviceFileName = fmt.Sprintf("%s_device.txt", res.ID)
		req.DeviceFile = file
	}

	imageFiles := form.File["images"]
	if len(imageFiles) > 0 {
		req.Images = make([]io.Reader, len(imageFiles))
		req.ImagesName = make([]string, len(imageFiles))
		for i, fileHeader := range imageFiles {
			file, err := fileHeader.Open()
			if err != nil {
				log.Error(err)
				badRequest(g)
				return
			}
			defer file.Close()
			req.ImagesName[i] = fmt.Sprintf("%s_fb_%d%s", res.ID, i, filepath.Ext(fileHeader.Filename))
			log.Info("image file")
			req.Images[i] = file
		}
	}

	if err := modb.FeedbackPost(&req); err != nil {
		log.Error(err)
		badRequest(g)
		return
	}
	log.Infof("创建反馈成功 %s", res.ID)

	okData(g, res)
}
func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func fbsGet(g *gin.Context) {
	log.Infof("获取反馈列表")
	feedbacks, err := modb.FeedbacksGet()
	if err != nil {
		log.Error(err)
		internalServerError(g)
		return
	}
	okData(g, feedbacks)
}

// 	g.JSON(sys.StatusOK, response{Feedbacks: feedbacks})
// }

// func fbGet(g *gin.Context) {
// 	type response struct {
// 		Feedback modb.Feedback `json:"feedback"`
// 	}

// 	goid := g.MustGet("goid").(primitive.ObjectID)
// 	fbid := g.Param("fbid")

// 	feedback, err := modb.FeedbackGet(goid, fbid)
// 	if err != nil {
// 		log.Error(err)
// 		badRequest(g)
// 		return
// 	}

// 	g.JSON(sys.StatusOK, response{Feedback: feedback})
// }
// func fbPut(g *gin.Context) {
// 	type response struct {
// 		Feedback modb.Feedback `json:"feedback"`
// 	}

// 	goid := g.MustGet("goid").(primitive.ObjectID)
// 	fbid := g.Param("fbid")

// 	var req modb.RequestFeedbackPut
// 	if err := g.ShouldBindBodyWithJSON(&req); err != nil {
// 		log.Error(err)
// 		badRequest(g)
// 		return
// 	}

// 	feedback, err := modb.FeedbackPut(goid, fbid, &req)
// 	if err != nil {
// 		log.Error(err)
// 		badRequest(g)
// 		return
// 	}

// 	g.JSON(sys.StatusOK, response{Feedback: feedback})
// }
