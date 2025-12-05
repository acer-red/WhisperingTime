package minio

import (
	"context"
	"fmt"

	log "github.com/tengfei-xy/go-log"

	"sync"
	"time"

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

// Start 启动初始化单例 MinIO 客户端
func Start(cfg Config) error {
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
