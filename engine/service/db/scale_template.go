package db

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

// ScaleTemplateModel stores encrypted scale templates.
type ScaleTemplateModel struct {
	ID                uuid.UUID `gorm:"type:uuid;primaryKey;default:uuidv7()"`
	UID               uuid.UUID `gorm:"column:uid;type:uuid;not null;index"`
	EncryptedMetadata []byte    `gorm:"column:encrypted_metadata;type:bytea;not null"`
	CreatedAt         time.Time `gorm:"column:created_at;autoCreateTime"`
}

func (ScaleTemplateModel) TableName() string { return "scale_template" }

type ScaleTemplateRecord struct {
	ID                string    `json:"id"`
	EncryptedMetadata []byte    `json:"encrypted_metadata"`
	CreateAt          time.Time `json:"created_at"`
}

func ScaleTemplateCreate(uid string, encryptedMetadata []byte) (string, error) {
	if uid == "" {
		return "", errors.New("invalid user id")
	}
	if len(encryptedMetadata) == 0 {
		return "", errors.New("encrypted_metadata is empty")
	}

	var id uuid.UUID
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return "", err
	}

	st := ScaleTemplateModel{
		UID:               uidUUID,
		EncryptedMetadata: encryptedMetadata,
		CreatedAt:         time.Now(),
	}

	if err := DB.Create(&st).Error; err != nil {
		return "", err
	}
	id = st.ID
	return id.String(), nil
}

func ScaleTemplateUpdate(uid string, id string, encryptedMetadata []byte) error {
	if uid == "" {
		return errors.New("invalid user id")
	}
	if len(encryptedMetadata) == 0 {
		return errors.New("encrypted_metadata is empty")
	}
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return err
	}
	idUUID, err := uuid.Parse(id)
	if err != nil {
		return err
	}
	return DB.Model(&ScaleTemplateModel{}).
		Where("uid = ? AND id = ?", uidUUID, idUUID).
		Update("encrypted_metadata", encryptedMetadata).Error
}

func ScaleTemplatesList(uid string) ([]ScaleTemplateRecord, error) {
	if uid == "" {
		return nil, errors.New("invalid user id")
	}

	var templates []ScaleTemplateModel
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return nil, err
	}
	if err := DB.Where("uid = ?", uidUUID).Order("created_at desc").Find(&templates).Error; err != nil {
		return nil, err
	}

	var records []ScaleTemplateRecord
	for _, t := range templates {
		records = append(records, ScaleTemplateRecord{
			ID:                t.ID.String(),
			EncryptedMetadata: t.EncryptedMetadata,
			CreateAt:          t.CreatedAt,
		})
	}
	return records, nil
}

func ScaleTemplateDelete(uid string, id string) error {
	if uid == "" {
		return errors.New("invalid user id")
	}
	if id == "" {
		return nil
	}
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return err
	}
	idUUID, err := uuid.Parse(id)
	if err != nil {
		return err
	}
	return DB.Where("uid = ? AND id = ?", uidUUID, idUUID).Delete(&ScaleTemplateModel{}).Error
}
