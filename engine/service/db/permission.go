package db

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

const (
	ResourceTypeTheme = "theme"
	ResourceTypeGroup = "group"
	ResourceTypeDoc   = "doc"

	RoleOwner  = "owner"
	RoleEditor = "editor"
	RoleViewer = "viewer"
)

// PermissionModel stores the database record binding a user to a resource.
type PermissionModel struct {
	ID           int64     `gorm:"primaryKey"`
	UID          uuid.UUID `gorm:"column:uid;type:uuid;not null;uniqueIndex:uni_permission_user_resource,priority:1"`
	ResourceType string    `gorm:"column:resource_type;type:text;not null;uniqueIndex:uni_permission_user_resource,priority:2"`
	ResourceID   uuid.UUID `gorm:"column:resource_id;type:uuid;not null;uniqueIndex:uni_permission_user_resource,priority:3"`
	EncryptedKey []byte    `gorm:"column:encrypted_key;type:bytea;not null"`
	Role         string    `gorm:"column:role;type:text;not null"`
	CreatedAt    time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt    time.Time `gorm:"column:updated_at;autoUpdateTime"`
}

func (PermissionModel) TableName() string { return "permission" }

// Permission stores the envelope-encrypted data key binding between a user and a resource.
type Permission struct {
	UserID       string    `json:"user_id"`
	ResourceID   string    `json:"resource_id"`
	ResourceType string    `json:"resource_type"`
	Role         string    `json:"role"`
	EncryptedKey []byte    `json:"encrypted_key"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// PermissionUpsert stores or updates a permission record for the given user and resource.
func PermissionUpsert(userID string, resourceID, resourceType, role string, encryptedKey []byte) error {
	if userID == "" {
		return errors.New("missing user id")
	}
	uidUUID, err := uuid.Parse(userID)
	if err != nil {
		return err
	}
	resUUID, err := uuid.Parse(resourceID)
	if err != nil {
		return err
	}

	var perm PermissionModel

	err = DB.Where("uid = ? AND resource_id = ? AND resource_type = ?", uidUUID, resUUID, resourceType).First(&perm).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		newPerm := PermissionModel{
			UID:          uidUUID,
			ResourceID:   resUUID,
			ResourceType: resourceType,
			Role:         role,
			EncryptedKey: encryptedKey,
			CreatedAt:    time.Now(),
			UpdatedAt:    time.Now(),
		}
		return DB.Create(&newPerm).Error
	} else if err != nil {
		return err
	}

	perm.Role = role
	perm.EncryptedKey = encryptedKey
	perm.UpdatedAt = time.Now()
	return DB.Save(&perm).Error
}

func PermissionGet(userID string, resourceType, resourceID string) (Permission, error) {
	uidUUID, err := uuid.Parse(userID)
	if err != nil {
		return Permission{}, err
	}
	resUUID, err := uuid.Parse(resourceID)
	if err != nil {
		return Permission{}, err
	}

	var p PermissionModel
	err = DB.Where("uid = ? AND resource_id = ? AND resource_type = ?", uidUUID, resUUID, resourceType).First(&p).Error
	if err != nil {
		return Permission{}, err
	}
	return Permission{
		UserID:       p.UID.String(),
		ResourceID:   p.ResourceID.String(),
		ResourceType: p.ResourceType,
		Role:         p.Role,
		EncryptedKey: p.EncryptedKey,
		CreatedAt:    p.CreatedAt,
		UpdatedAt:    p.UpdatedAt,
	}, nil
}

// PermissionsFor returns permissions for a user and resource ids keyed by resource_id.
func PermissionsFor(userID string, resourceType string, resourceIDs []string) (map[string]Permission, error) {
	result := make(map[string]Permission)
	if userID == "" || len(resourceIDs) == 0 {
		return result, nil
	}
	uidUUID, err := uuid.Parse(userID)
	if err != nil {
		return nil, err
	}
	var resUUIDs []uuid.UUID
	for _, id := range resourceIDs {
		u, err := uuid.Parse(id)
		if err != nil {
			return nil, err
		}
		resUUIDs = append(resUUIDs, u)
	}

	var perms []PermissionModel
	err = DB.Where("uid = ? AND resource_type = ? AND resource_id IN ?", uidUUID, resourceType, resUUIDs).Find(&perms).Error
	if err != nil {
		return nil, err
	}

	for _, p := range perms {
		result[p.ResourceID.String()] = Permission{
			UserID:       p.UID.String(),
			ResourceID:   p.ResourceID.String(),
			ResourceType: p.ResourceType,
			Role:         p.Role,
			EncryptedKey: p.EncryptedKey,
			CreatedAt:    p.CreatedAt,
			UpdatedAt:    p.UpdatedAt,
		}
	}

	return result, nil
}

func PermissionDelete(resourceType string, resourceIDs []string) error {
	if len(resourceIDs) == 0 {
		return nil
	}
	return DB.Where("resource_type = ? AND resource_id IN ?", resourceType, resourceIDs).Delete(&PermissionModel{}).Error
}
