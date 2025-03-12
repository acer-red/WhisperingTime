package modb

import (
	"context"
	"io"
	"time"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
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

func (req *RequestFeedbackPost) Put() error {
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
