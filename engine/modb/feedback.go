package modb

import (
	"context"
	"io"
	"time"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/gridfs"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type RequestFeedbackPost struct {
	FBID           string
	FbType         int
	Title          string
	Content        string
	DeviceFile     io.Reader
	DeviceFileName string
	Images         []io.Reader
	ImagesName     []string
}

func FeedbackPost(req *RequestFeedbackPost) error {
	if req.DeviceFile != nil {
		bucket, err := gridfs.NewBucket(db)
		if err != nil {
			panic(err)
		}

		uploadStream, err := bucket.OpenUploadStream(
			req.DeviceFileName,
			options.GridFSUpload().SetMetadata(map[string]string{"type": "txt"}), // 可选的元数据
		)
		if err != nil {
			log.Error(err)
			return err
		}
		defer uploadStream.Close()

		fileSize, err := io.Copy(uploadStream, req.DeviceFile)
		if err != nil {
			log.Error(err)
			return err
		}
		log.Infof("创建设备信息: %s(%s)", req.DeviceFileName, ByteCountSI(fileSize))
	}
	if len(req.Images) > 0 {
		bucket, err := gridfs.NewBucket(db)
		if err != nil {
			panic(err)
		}

		for i, image := range req.Images {
			uploadStream, err := bucket.OpenUploadStream(
				req.ImagesName[i],
				options.GridFSUpload().SetMetadata(map[string]string{"type": "image"}), // 可选的元数据
			)
			if err != nil {
				log.Error(err)
				return err
			}
			defer uploadStream.Close()

			fileSize, err := io.Copy(uploadStream, image)
			if err != nil {
				log.Error(err)
				return err
			}
			log.Infof("创建图片: %s(%s)", req.ImagesName[i], ByteCountSI(fileSize))
		}
	}
	m := bson.M{
		"fbid":    req.FBID,
		"fb_type": req.FbType,
		"title":   req.Title,
		"content": req.Content,
		"device":  req.DeviceFileName,
		"images":  req.ImagesName,
		"create":  time.Now(),
		"update":  time.Now(),
	}
	_, err := db.Collection("feedback").InsertOne(context.TODO(), m)
	if err != nil {
		log.Error(err)
	}

	return nil
}

func FeedbacksGet() (any, error) {
	type response struct {
		FBID       string   `json:"fbid"`
		FbType     int32    `json:"fb_type"`
		Title      string   `json:"title"`
		Content    string   `json:"content"`
		DeviceFile string   `json:"device_file"`
		Images     []string `json:"images"`
		CRTime     string   `json:"crtime"`
		UPTime     string   `json:"uptime"`
	}
	var res []response
	cur, err := db.Collection("feedback").Find(context.TODO(), bson.M{})
	if err != nil {
		log.Error(err)
		return nil, err
	}
	defer cur.Close(context.Background())
	for cur.Next(context.Background()) {
		var m bson.M

		err := cur.Decode(&m)
		if err != nil {
			log.Error(err)
			return nil, err
		}
		fbid, _ := m["fbid"].(string)
		var fbType int32
		if v, ok := m["fb_type"].(int32); ok {
			fbType = v
		}
		title, _ := m["title"].(string)
		content, _ := m["content"].(string)
		deviceFile, _ := m["device"].(string)
		var images []string
		if v, ok := m["images"].([]string); ok {
			images = v
		}
		crtime := m["crtime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05")
		uptime := m["uptime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05")

		res = append(res, response{
			FBID:       fbid,
			FbType:     fbType,
			Title:      title,
			Content:    content,
			DeviceFile: deviceFile,
			Images:     images,
			CRTime:     crtime,
			UPTime:     uptime,
		})
	}
	if err := cur.Err(); err != nil {
		log.Error(err)
		return nil, err
	}
	return res, nil

}
