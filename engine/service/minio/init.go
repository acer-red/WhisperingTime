package minio

import (
	"context"
	"fmt"
	"time"

	log "github.com/tengfei-xy/go-log"

	"sync"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

// MinioClient 封装 minio.Client
type MinioClient struct {
	client     *minio.Client
	bucketName string
}

var (
	instance *MinioClient
	once     sync.Once
)

type Config struct {
	Endpoint        string `yaml:"endpoint"`
	AccessKeyID     string `yaml:"access_key_id"`
	SecretAccessKey string `yaml:"secret_access_key"`
	BucketName      string `yaml:"bucket_name"`
	UseSSL          bool   `yaml:"use_ssl"`
}

// 启动初始化单例 MinIO 客户端
func Init(cfg Config) error {
	var err error
	once.Do(func() {
		// 1. 初始化 MinIO 客户端对象
		client, initErr := minio.New(cfg.Endpoint, &minio.Options{
			Creds:  credentials.NewStaticV4(cfg.AccessKeyID, cfg.SecretAccessKey, ""),
			Secure: cfg.UseSSL,
		})

		if initErr != nil {
			err = initErr
			return
		}

		instance = &MinioClient{
			client:     client,
			bucketName: cfg.BucketName,
		}

		// 2. 检查连接是否可用 (可选，但推荐)
		// 设置一个短的超时时间来验证连接
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		// 尝试列出 bucket 来验证权限和网络
		_, err = client.ListBuckets(ctx)
		if err != nil {
			err = fmt.Errorf("failed to connect to minio: %w", err)
			return
		}

		// 3. 自动创建 Bucket (可选最佳实践)
		err = instance.ensureBucketExists(context.Background())
	})

	return err
}

// GetClient 获取单例实例
func GetClient() *MinioClient {
	if instance == nil {
		log.Fatal("MinIO client not initialized. Call InitMinio first.")
	}
	return instance
}

// ensureBucketExists 检查并创建 Bucket
func (m *MinioClient) ensureBucketExists(ctx context.Context) error {
	exists, err := m.client.BucketExists(ctx, m.bucketName)
	if err != nil {
		return err
	}
	if !exists {
		err = m.client.MakeBucket(ctx, m.bucketName, minio.MakeBucketOptions{})
		if err != nil {
			return err
		}
	}
	return nil
}

// UploadFile 示例：封装上传逻辑
func (m *MinioClient) UploadFile(ctx context.Context, objectName string, filePath string, contentType string) (minio.UploadInfo, error) {
	// 使用 FPutObject 上传本地文件
	// 对于流式上传 (如 HTTP Request Body)，请使用 PutObject
	info, err := m.client.FPutObject(ctx, m.bucketName, objectName, filePath, minio.PutObjectOptions{
		ContentType: contentType,
	})
	if err != nil {
		return minio.UploadInfo{}, err
	}
	return info, nil
}

// PresignPut generates a presigned PUT URL for direct upload.
func (m *MinioClient) PresignPut(ctx context.Context, objectName string, contentType string, expires time.Duration) (string, time.Time, error) {
	if expires <= 0 {
		expires = 15 * time.Minute
	}
	url, err := m.client.PresignedPutObject(ctx, m.bucketName, objectName, expires)
	if err != nil {
		return "", time.Time{}, err
	}
	return url.String(), time.Now().Add(expires), nil
}

// PresignGet generates a presigned GET URL for direct download.
func (m *MinioClient) PresignGet(ctx context.Context, objectName string, expires time.Duration) (string, time.Time, error) {
	if expires <= 0 {
		expires = 15 * time.Minute
	}
	url, err := m.client.PresignedGetObject(ctx, m.bucketName, objectName, expires, nil)
	if err != nil {
		return "", time.Time{}, err
	}
	return url.String(), time.Now().Add(expires), nil
}

// DeleteObject removes an object from the bucket.
func (m *MinioClient) DeleteObject(ctx context.Context, objectName string) error {
	return m.client.RemoveObject(ctx, m.bucketName, objectName, minio.RemoveObjectOptions{})
}
