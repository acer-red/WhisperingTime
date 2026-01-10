package db

import (
	"time"

	"github.com/google/uuid"
	"github.com/tengfei-xy/go-log"
	"gorm.io/gorm"

	m "github.com/acer-red/whisperingtime/engine/model"
	"github.com/acer-red/whisperingtime/engine/util"
)

// DocModel is the gorm model for documents.
type DocModel struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuidv7()"`
	UID             uuid.UUID      `gorm:"column:uid;type:uuid;not null;index"`
	GID             uuid.UUID      `gorm:"column:gid;type:uuid;not null;index"`
	Title           []byte         `gorm:"column:title;type:bytea"`
	Rich            []byte         `gorm:"column:rich;type:bytea"`
	Scales          []byte         `gorm:"column:scales;type:bytea"`
	Level           []byte         `gorm:"column:level;type:bytea"`
	EncryptedKey    []byte         `gorm:"column:encrypted_key;type:bytea;not null"`
	IsShowTool      bool           `gorm:"column:is_show_tool;not null;default:false"`
	DisplayPriority int            `gorm:"column:display_priority;not null;default:0"`
	CreatedAt       time.Time      `gorm:"column:create_at;autoCreateTime"`
	UpdatedAt       time.Time      `gorm:"column:update_at;autoUpdateTime"`
	DeletedAt       gorm.DeletedAt `gorm:"column:deleted_at;index"`
}

func (DocModel) TableName() string { return "doc" }

type RequestDocPost struct {
	Data struct {
		Content      m.DocContent `json:"content"`
		CreateAt     string       `json:"createAt"`
		Config       *m.DocConfig `json:"config"`
		EncryptedKey []byte       `json:"encrypted_key"`
	} `json:"data"`
}

type RequestDocPut struct {
	Doc struct {
		Content  *m.DocContent `json:"content,omitempty" bson:"content"`
		CreateAt *string       `json:"createAt,omitempty"`
		UpdateAt *string       `json:"updateAt,omitempty"`
		Config   *m.DocConfig  `json:"config,omitempty" bson:"config"`
		ID       *string       `json:"id" bson:"did"`
	} `json:"data"`
}
type DocFilter struct {
	Year  int `json:"year"`
	Month int `json:"month"`
}

func DocsGet(groupID string, f DocFilter) ([]m.Doc, error) {
	var results []m.Doc
	var docs []DocModel

	gidUUID, err := uuid.Parse(groupID)
	if err != nil {
		return nil, err
	}

	query := DB.Where("gid = ?", gidUUID)

	if f.Year != 0 && f.Month != 0 {
		startDate := time.Date(f.Year, time.Month(f.Month), 1, 0, 0, 0, 0, time.Local)
		endDate := time.Date(f.Year, time.Month(f.Month+1), 1, 0, 0, 0, 0, time.Local)
		query = query.Where("created_at >= ? AND created_at < ?", startDate, endDate)
	}

	if err := query.Find(&docs).Error; err != nil {
		log.Error(err)
		return nil, err
	}

	for _, d := range docs {
		cfg := &m.DocConfig{
			IsShowTool:      d.IsShowTool,
			DisplayPriority: d.DisplayPriority,
		}

		results = append(results, m.Doc{
			Content: m.DocContent{
				Title:  d.Title,
				Scales: d.Scales,
				Rich:   d.Rich,
				Level:  d.Level,
			},
			CreateAt: d.CreatedAt,
			UpdateAt: d.UpdatedAt,
			Config:   cfg,
			ID:       d.ID.String(),
		})
	}

	return results, nil
}
func DocPost(uid string, groupID string, req *RequestDocPost) (string, error) {
	var didUUID uuid.UUID
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return "", err
	}
	gidUUID, err := uuid.Parse(groupID)
	if err != nil {
		return "", err
	}

	newDoc := DocModel{
		UID:          uidUUID,
		GID:          gidUUID,
		Title:        req.Data.Content.Title,
		Rich:         req.Data.Content.Rich,
		Scales:       req.Data.Content.Scales,
		Level:        req.Data.Content.Level,
		CreatedAt:    util.StringtoTime(req.Data.CreateAt),
		UpdatedAt:    util.StringtoTime(req.Data.CreateAt),
		EncryptedKey: req.Data.EncryptedKey,
	}

	if req.Data.Config != nil {
		newDoc.IsShowTool = req.Data.Config.IsShowTool
		newDoc.DisplayPriority = req.Data.Config.DisplayPriority
	}

	if err := DB.Create(&newDoc).Error; err != nil {
		return "", err
	}
	didUUID = newDoc.ID
	did := didUUID.String()

	if err := PermissionUpsert(uid, did, ResourceTypeDoc, RoleOwner, req.Data.EncryptedKey); err != nil {
		return "", err
	}

	if err := RefreshGroupUpdateAt(groupID, true); err != nil {
		log.Errorf("failed to refresh group updateAt: %v", err)
		// Non-critical, continue
	}

	return did, nil
}

func DocPut(groupID string, docID string, req *RequestDocPut) error {
	m := make(map[string]interface{})

	if req.Doc.Content != nil {
		if req.Doc.Content.Title != nil {
			m["title"] = req.Doc.Content.Title
		}
		if req.Doc.Content.Rich != nil {
			m["rich"] = req.Doc.Content.Rich // 假设数据库字段名
		}
		if req.Doc.Content.Scales != nil {
			m["scales"] = req.Doc.Content.Scales
		}
		// ... 其他字段
	}

	if req.Doc.UpdateAt != nil {
		m["update_at"] = util.StringtoTime(*req.Doc.UpdateAt)
	}

	if req.Doc.Config != nil {
		m["is_show_tool"] = req.Doc.Config.IsShowTool
		m["display_priority"] = req.Doc.Config.DisplayPriority
	}

	if len(m) > 0 {
		didUUID, err := uuid.Parse(docID)
		if err != nil {
			return err
		}
		gidUUID, err := uuid.Parse(groupID)
		if err != nil {
			return err
		}
		if err := DB.Model(&DocModel{}).Where("id = ? AND gid = ?", didUUID, gidUUID).Updates(m).Error; err != nil {
			return err
		}
		return RefreshGroupUpdateAt(groupID, true)
	}
	return nil
}

// ... 提取 Bytes 的辅助函数不再需要，因为 GORM 会自动映射 []byte 到 bytea

func DocDelete(groupID string, docID string) error {
	didUUID, err := uuid.Parse(docID)
	if err != nil {
		return err
	}
	gidUUID, err := uuid.Parse(groupID)
	if err != nil {
		return err
	}

	var doc DocModel
	if err := DB.Where("id = ? AND gid = ?", didUUID, gidUUID).First(&doc).Error; err != nil {
		return err
	}

	if err := DB.Delete(&doc).Error; err != nil {
		return err
	}

	if err := PermissionDelete(ResourceTypeDoc, []string{doc.ID.String()}); err != nil {
		return err
	}

	return RefreshGroupUpdateAt(groupID, true)
}

// 根据 Group ID 删除所有印迹
func DocDeleteFromGroupID(groupID string) error {
	gidUUID, err := uuid.Parse(groupID)
	if err != nil {
		return err
	}
	return DB.Where("gid = ?", gidUUID).Delete(&DocModel{}).Error
}
