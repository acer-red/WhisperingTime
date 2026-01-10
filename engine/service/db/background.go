package db

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
	log "github.com/tengfei-xy/go-log"
)

const (
	JobTypeExportGroupConfig = "ExportGroupConfig"
	JobTypeExportAllConfig   = "ExportAllConfig"
)

// 定义任务状态的常量
const (
	JobStatusPending   string = "pending"
	JobStatusRunning   string = "running"
	JobStatusCompleted string = "completed"
	JobStatusFailed    string = "failed"
)
const (
	JobPriority0 int = 0
)

// BGJobModel maps to bg_job rows.
type BGJobModel struct {
	ID          uuid.UUID  `gorm:"type:uuid;primaryKey;default:uuidv7()"`
	UID         uuid.UUID  `gorm:"column:uid;type:uuid;not null;index"`
	JobType     string     `gorm:"column:job_type;type:text;not null"`
	Name        string     `gorm:"column:name;type:text;not null"`
	Status      string     `gorm:"column:status;type:text;not null;default:pending"`
	Payload     []byte     `gorm:"column:payload;type:bytea"`
	Result      []byte     `gorm:"column:result;type:bytea"`
	ErrorCode   int        `gorm:"column:error_code"`
	ErrorMsg    string     `gorm:"column:error_message;type:text"`
	Priority    int        `gorm:"column:priority;not null;default:0"`
	RetryCount  int        `gorm:"column:retry_count;not null;default:0"`
	CreatedAt   time.Time  `gorm:"column:created_at;autoCreateTime"`
	StartedAt   *time.Time `gorm:"column:started_at"`
	CompletedAt *time.Time `gorm:"column:completed_at"`
}

func (BGJobModel) TableName() string { return "bg_job" }

// JobError 用于在 'error' 字段中存储结构化的错误信息
type JobError struct {
	Code    int    `json:"code,omitempty"`
	Message string `json:"message"`
}

// BGJob 结构体适配 API
type BGJob struct {
	ID          string      `json:"id"`
	JobType     string      `json:"job_type"`
	Name        string      `json:"name"`
	Status      string      `json:"status"`
	CreatedAt   time.Time   `json:"created_at"`
	StartedAt   *time.Time  `json:"started_at"`
	CompletedAt *time.Time  `json:"completed_at"`
	Priority    int         `json:"priority"`
	RetryCount  int         `json:"retry_count"`
	Result      interface{} `json:"result"`
	Error       *JobError   `json:"error"`
}

func createBGJob(uid string, JobType string, JobPriority int, name string) (string, string, error) {
	log.Infof("创建后台任务:%s", name)

	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return "", "", err
	}

	job := BGJobModel{
		UID:      uidUUID,
		JobType:  JobType,
		Name:     name,
		Status:   JobStatusPending,
		Priority: JobPriority,
	}

	if err := DB.Create(&job).Error; err != nil {
		return "", "", err
	}
	return job.ID.String(), job.ID.String(), nil
}

// SetJobError helper function
func SetJobError(jobID string, je JobError) error {
	return DB.Model(&BGJobModel{}).Where("id = ?", jobID).Updates(map[string]interface{}{
		"status":        JobStatusFailed,
		"completed_at":  time.Now(),
		"error_code":    je.Code,
		"error_message": je.Message,
	}).Error
}

// Helper methods for job updates, accepting ID
func SetJobRunning(jobID string) error {
	return DB.Model(&BGJobModel{}).Where("id = ?", jobID).Updates(map[string]interface{}{
		"status":     JobStatusRunning,
		"started_at": time.Now(),
	}).Error
}

func SetJobCompleted(jobID string, payload interface{}) error {
	// Payload serialization
	payloadBytes, _ := json.Marshal(payload)

	return DB.Model(&BGJobModel{}).Where("id = ?", jobID).Updates(map[string]interface{}{
		"status":       JobStatusCompleted,
		"completed_at": time.Now(),
		"result":       payloadBytes, // Assuming result is stored here
	}).Error
}

// BGJobGet 获取指定的后台任务
func BGJobGet(userID string, jobID string) (*BGJob, error) {
	uidUUID, err := uuid.Parse(userID)
	if err != nil {
		return nil, err
	}
	jobUUID, err := uuid.Parse(jobID)
	if err != nil {
		return nil, err
	}
	var job BGJobModel
	if err := DB.Where("uid = ? AND id = ?", uidUUID, jobUUID).First(&job).Error; err != nil {
		return nil, err
	}

	res := &BGJob{
		ID:          job.ID.String(),
		JobType:     job.JobType,
		Name:        job.Name,
		Status:      job.Status,
		CreatedAt:   job.CreatedAt,
		StartedAt:   job.StartedAt,
		CompletedAt: job.CompletedAt,
		Priority:    job.Priority,
		RetryCount:  job.RetryCount,
	}

	if job.ErrorCode != 0 || job.ErrorMsg != "" {
		res.Error = &JobError{Code: job.ErrorCode, Message: job.ErrorMsg}
	}
	if len(job.Result) > 0 {
		var r interface{}
		_ = json.Unmarshal(job.Result, &r)
		res.Result = r
	}

	return res, nil
}

// BGJobsGet 获取用户的所有后台任务
func BGJobsGet(userID string) ([]BGJob, error) {
	uidUUID, err := uuid.Parse(userID)
	if err != nil {
		return nil, err
	}
	var jobs []BGJobModel
	if err := DB.Where("uid = ?", uidUUID).Order("created_at desc").Find(&jobs).Error; err != nil {
		return nil, err
	}

	var results []BGJob
	for _, j := range jobs {
		rec := BGJob{
			ID:          j.ID.String(),
			JobType:     j.JobType,
			Name:        j.Name,
			Status:      j.Status,
			CreatedAt:   j.CreatedAt,
			StartedAt:   j.StartedAt,
			CompletedAt: j.CompletedAt,
			Priority:    j.Priority,
			RetryCount:  j.RetryCount,
		}

		if j.ErrorCode != 0 || j.ErrorMsg != "" {
			rec.Error = &JobError{Code: j.ErrorCode, Message: j.ErrorMsg}
		}
		if len(j.Result) > 0 {
			var r interface{}
			_ = json.Unmarshal(j.Result, &r)
			rec.Result = r
		}

		results = append(results, rec)
	}
	return results, nil
}

// BGJobDelete 删除指定的后台任务
func BGJobDelete(userID string, jobID string) error {
	uidUUID, err := uuid.Parse(userID)
	if err != nil {
		return err
	}
	jobUUID, err := uuid.Parse(jobID)
	if err != nil {
		return err
	}
	result := DB.Where("uid = ? AND id = ?", uidUUID, jobUUID).Delete(&BGJobModel{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		log.Warn("未找到要删除的任务")
	}
	return nil
}
