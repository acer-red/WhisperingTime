package modb

import (
	"context"
	"time"

	"github.com/tengfei-xy/go-log"
	"github.com/tengfei-xy/whisperingtime/engine/sys"
	"go.mongodb.org/mongo-driver/bson"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

const (
	JobTypeExportGroupConfig = "ExportGroupConfig"
	JobTypeExportAllConfig   = "ExportAllConfig"
)

// 定义任务状态的常量，这是最佳实践
const (
	JobStatusPending   string = "pending"
	JobStatusRunning   string = "running"
	JobStatusCompleted string = "completed"
	JobStatusFailed    string = "failed"
)
const (
	JobPriority0 int = 0
)

// BGJob 是 'backgroundJobs' 集合的 Go 映射
type BGJobOID struct {
	_ID primitive.ObjectID `json:"-" bson:"_id,omitempty"`
}
type BGJob struct {
	// 核心字段
	BGJobOID
	ID      string             `json:"id" bson:"id,omitempty"` // 用户可见的任务ID (UUID)
	UOID    primitive.ObjectID `json:"-" bson:"uoid"`          // 用户ID (不返回给前端)
	JobType string             `json:"jobType" bson:"jobType"` // 任务类型
	Name    string             `json:"name" bson:"name"`       // 任务名称
	Status  string             `json:"status" bson:"status"`   // 任务状态

	// 'status' 强关联的时间戳
	CreatedAt   time.Time  `json:"createdAt" bson:"createdAt"`                         // 任务创建时间 (pending时)
	StartedAt   *time.Time `json:"startedAt,omitempty" bson:"startedAt,omitempty"`     // 任务开始时间 (running时)
	CompletedAt *time.Time `json:"completedAt,omitempty" bson:"completedAt,omitempty"` // 任务结束时间 (completed/failed时)

	// 任务数据
	Payload primitive.M `json:"-" bson:"payload"`                         // 任务参数 (不返回给前端,敏感数据)
	Result  interface{} `json:"result,omitempty" bson:"result,omitempty"` // 成功结果
	Error   *JobError   `json:"error,omitempty" bson:"error,omitempty"`   // 失败详情

	// 调度与执行元数据
	Priority   int `json:"priority" bson:"priority"`     // 优先级, 0=default, 1=high
	RetryCount int `json:"retryCount" bson:"retryCount"` // 当前重试次数
}

// JobError 用于在 'error' 字段中存储结构化的错误信息
type JobError struct {
	Code    int    `bson:"code,omitempty"` // 业务错误码
	Message string `bson:"message"`        // 给开发者的错误信息
}

func createBGJob(uoid primitive.ObjectID, JobType string, JobPriority int, name string) (primitive.ObjectID, string, error) {
	log.Infof("创建后台任务:%s", name)

	// 生成 UUID 作为用户可见的任务 ID
	taskID := sys.CreateUUID()

	result, err := db.Collection("BGJob").InsertOne(context.TODO(), bson.M{
		"id":        taskID,
		"uoid":      uoid,
		"jobType":   JobType,
		"name":      name,
		"status":    JobStatusPending,
		"createdAt": time.Now(),
		"priority":  JobPriority,
	})
	if err != nil {
		return primitive.NilObjectID, "", err
	}
	return result.InsertedID.(primitive.ObjectID), taskID, nil
}
func (job *BGJobOID) SetError(je JobError) error {

	filter := bson.M{"_ID": job._ID}
	update := bson.M{
		"$set": bson.M{
			"status":      JobStatusFailed,
			"CompletedAt": time.Now(),
			"error":       je},
	}

	_, err := db.Collection("BGJob").UpdateOne(context.TODO(), filter, update)
	if err != nil {
		log.Error(err)
		return err
	}
	return nil
}
func (job *BGJobOID) SetJobRunning() error {
	filter := bson.M{"_id": job._ID}
	update := bson.M{
		"$set": bson.M{
			"status":    JobStatusRunning,
			"startedAt": time.Now(),
		},
	}
	_, err := db.Collection("BGJob").UpdateOne(context.TODO(), filter, update)
	if err != nil {
		job.SetError(JobError{
			Code:    1,
			Message: err.Error(),
		})
		log.Error(err)
		return err
	}
	return nil
}
func (job *BGJobOID) SetJobCompleted(payload primitive.M) error {
	filter := bson.M{"_id": job._ID}
	update := bson.M{
		"$set": bson.M{
			"status":      JobStatusCompleted,
			"CompletedAt": time.Now(),
			"error": bson.M{
				"code": 0,
			},
			"payload": payload,
		},
	}
	_, err := db.Collection("BGJob").UpdateOne(context.TODO(), filter, update)
	if err != nil {
		job.SetError(JobError{
			Code:    1,
			Message: err.Error(),
		})
		log.Error(err)
		return err
	}
	return nil
}

// BGJobGet 获取指定的后台任务
func BGJobGet(uoid primitive.ObjectID, bgjoid primitive.ObjectID) (*BGJob, error) {
	filter := bson.M{
		"_id":  bgjoid,
		"uoid": uoid,
	}

	var job BGJob
	err := db.Collection("BGJob").FindOne(context.TODO(), filter).Decode(&job)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	return &job, nil
}

// BGJobsGet 获取用户的所有后台任务
func BGJobsGet(uoid primitive.ObjectID) ([]BGJob, error) {
	filter := bson.M{
		"uoid": uoid,
	}

	var jobs []BGJob
	cursor, err := db.Collection("BGJob").Find(context.TODO(), filter)
	if err != nil {
		log.Error(err)
		return nil, err
	}
	defer cursor.Close(context.TODO())

	if err = cursor.All(context.TODO(), &jobs); err != nil {
		log.Error(err)
		return nil, err
	}

	return jobs, nil
}

// GetBGJOIDFromBGJID 从 BGJID 字符串获取 ObjectID
func GetBGJOIDFromBGJID(bgjid string) (primitive.ObjectID, error) {
	identified := bson.D{{Key: "id", Value: bgjid}}
	var result bson.M

	if err := db.Collection("BGJob").FindOne(context.TODO(), identified).Decode(&result); err != nil {
		return primitive.NilObjectID, err
	}

	id, ok := result["_id"].(primitive.ObjectID)
	if !ok {
		return primitive.NilObjectID, nil
	}

	return id, nil
}

// BGJobDelete 删除指定的后台任务
func BGJobDelete(uoid primitive.ObjectID, bgjoid primitive.ObjectID) error {
	filter := bson.M{
		"_id":  bgjoid,
		"uoid": uoid,
	}

	result, err := db.Collection("BGJob").DeleteOne(context.TODO(), filter)
	if err != nil {
		log.Error(err)
		return err
	}

	if result.DeletedCount == 0 {
		log.Warn("未找到要删除的任务")
	}

	return nil
}
