package db

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// FileMetaModel stores the DB representation of file metadata.
type FileMetaModel struct {
	ID                uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuidv7()"`
	UID               uuid.UUID      `gorm:"column:uid;type:uuid;not null;index"`
	DID               uuid.UUID      `gorm:"column:did;type:uuid;not null;index"`
	ObjectPath        string         `gorm:"column:object_path;type:text;not null"`
	Mime              string         `gorm:"column:mime;type:text;not null"`
	Size              int64          `gorm:"column:size"`
	EncryptedKey      []byte         `gorm:"column:encrypted_key;type:bytea;not null"`
	IV                []byte         `gorm:"column:iv;type:bytea;not null"`
	EncryptedMetadata []byte         `gorm:"column:encrypted_metadata;type:bytea;not null"`
	CreatedAt         time.Time      `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt         time.Time      `gorm:"column:updated_at;autoUpdateTime"`
	DeletedAt         gorm.DeletedAt `gorm:"column:deleted_at;index"`
}

func (FileMetaModel) TableName() string { return "filemeta" }

// FileMeta stores object storage metadata and envelope encryption info.
type FileMeta struct {
	ID                string    `json:"id"`
	UID               string    `json:"uid"`
	DocID             string    `json:"doc_id"`
	ObjectPath        string    `json:"object_path"`
	Mime              string    `json:"mime"`
	Size              int64     `json:"size"`
	EncryptedKey      []byte    `json:"encrypted_key"`
	IV                []byte    `json:"iv,omitempty"`
	EncryptedMetadata []byte    `json:"encrypted_metadata,omitempty"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
	ThemeID           string    `json:"theme_id,omitempty"`
	GroupID           string    `json:"group_id,omitempty"`
}

// FileMetaCreate inserts a new file metadata record and returns its ID.
func FileMetaCreate(ctx context.Context, meta *FileMeta) (string, error) {
	if meta == nil {
		return "", errors.New("nil file meta")
	}

	if meta.UID == "" {
		return "", errors.New("missing user uid in file meta")
	}
	uidUUID, err := uuid.Parse(meta.UID)
	if err != nil {
		return "", err
	}
	didUUID, err := uuid.Parse(meta.DocID)
	if err != nil {
		return "", err
	}
	newMeta := FileMetaModel{
		UID:               uidUUID,
		DID:               didUUID,
		ObjectPath:        meta.ObjectPath,
		Mime:              meta.Mime,
		Size:              meta.Size,
		EncryptedKey:      meta.EncryptedKey,
		IV:                meta.IV,
		EncryptedMetadata: meta.EncryptedMetadata,
		CreatedAt:         time.Now(),
		UpdatedAt:         time.Now(),
	}

	if err := DB.Create(&newMeta).Error; err != nil {
		return "", err
	}

	meta.ID = newMeta.ID.String()
	return meta.ID, nil
}

// FileMetaGet retrieves file metadata by ID.
func FileMetaGet(ctx context.Context, fileID string) (*FileMeta, error) {
	fileUUID, err := uuid.Parse(fileID)
	if err != nil {
		return nil, err
	}
	var fm FileMetaModel
	if err := DB.Where("id = ?", fileUUID).First(&fm).Error; err != nil {
		return nil, err
	}
	res := &FileMeta{
		ID:                fm.ID.String(),
		DocID:             fm.DID.String(),
		ObjectPath:        fm.ObjectPath,
		Mime:              fm.Mime,
		Size:              fm.Size,
		EncryptedKey:      fm.EncryptedKey,
		IV:                fm.IV,
		EncryptedMetadata: fm.EncryptedMetadata,
		CreatedAt:         fm.CreatedAt,
		UpdatedAt:         fm.UpdatedAt,
		UID:               fm.UID.String(),
	}
	_ = hydrateHierarchy(res)
	return res, nil
}

// FileMetaListByUser lists all file metadata for a user.
func FileMetaListByUser(ctx context.Context, uidStr string) ([]FileMeta, error) {
	var files []FileMetaModel
	uidUUID, err := uuid.Parse(uidStr)
	if err != nil {
		return nil, err
	}
	if err := DB.Where("uid = ?", uidUUID).Find(&files).Error; err != nil {
		return nil, err
	}

	var result []FileMeta
	for _, fm := range files {
		item := FileMeta{
			ID:                fm.ID.String(),
			UID:               uidStr,
			DocID:             fm.DID.String(),
			ObjectPath:        fm.ObjectPath,
			Mime:              fm.Mime,
			Size:              fm.Size,
			EncryptedKey:      fm.EncryptedKey,
			IV:                fm.IV,
			EncryptedMetadata: fm.EncryptedMetadata,
			CreatedAt:         fm.CreatedAt,
			UpdatedAt:         fm.UpdatedAt,
		}
		_ = hydrateHierarchy(&item)
		result = append(result, item)
	}
	return result, nil
}

// FileMetaListByDoc lists file metadata for a specific document.
func FileMetaListByDoc(ctx context.Context, docID string) ([]FileMeta, error) {
	var files []FileMetaModel
	didUUID, err := uuid.Parse(docID)
	if err != nil {
		return nil, err
	}
	if err := DB.Where("did = ?", didUUID).Find(&files).Error; err != nil {
		return nil, err
	}

	var result []FileMeta
	for _, fm := range files {
		item := FileMeta{
			ID:                fm.ID.String(),
			DocID:             fm.DID.String(),
			ObjectPath:        fm.ObjectPath,
			Mime:              fm.Mime,
			Size:              fm.Size,
			EncryptedKey:      fm.EncryptedKey,
			IV:                fm.IV,
			EncryptedMetadata: fm.EncryptedMetadata,
			CreatedAt:         fm.CreatedAt,
			UpdatedAt:         fm.UpdatedAt,
		}
		_ = hydrateHierarchy(&item)
		result = append(result, item)
	}
	return result, nil
}

// FileMetaDelete removes filemeta by id.
func FileMetaDelete(ctx context.Context, fileID string) (*FileMeta, error) {
	fileUUID, err := uuid.Parse(fileID)
	if err != nil {
		return nil, err
	}
	var fm FileMetaModel
	if err := DB.Where("id = ?", fileUUID).First(&fm).Error; err != nil {
		return nil, err
	}

	if err := DB.Delete(&fm).Error; err != nil {
		return nil, err
	}

	item := &FileMeta{
		ID:                fm.ID.String(),
		DocID:             fm.DID.String(),
		ObjectPath:        fm.ObjectPath,
		Mime:              fm.Mime,
		Size:              fm.Size,
		EncryptedKey:      fm.EncryptedKey,
		IV:                fm.IV,
		EncryptedMetadata: fm.EncryptedMetadata,
		CreatedAt:         fm.CreatedAt,
		UpdatedAt:         fm.UpdatedAt,
		UID:               fm.UID.String(),
	}
	_ = hydrateHierarchy(item)
	return item, nil
}

// hydrateHierarchy fills GroupID and ThemeID based on the doc relationship to satisfy API responses.
func hydrateHierarchy(meta *FileMeta) error {
	if meta == nil || meta.DocID == "" {
		return nil
	}
	didUUID, err := uuid.Parse(meta.DocID)
	if err != nil {
		return err
	}

	var doc DocModel
	if err := DB.Select("gid").Where("id = ?", didUUID).First(&doc).Error; err != nil {
		return err
	}
	meta.GroupID = doc.GID.String()

	if doc.GID == uuid.Nil {
		return nil
	}
	var group GroupModel
	if err := DB.Select("tid").Where("id = ?", doc.GID).First(&group).Error; err != nil {
		return err
	}
	meta.ThemeID = group.TID.String()
	return nil
}
