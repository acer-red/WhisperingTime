package db

import (
	"time"

	"github.com/google/uuid"
	log "github.com/tengfei-xy/go-log"
	"gorm.io/gorm"

	m "github.com/acer-red/whisperingtime/engine/model"
)

// ThemeModel is the gorm model for theme rows.
type ThemeModel struct {
	ID           uuid.UUID      `gorm:"type:uuid;primaryKey;default:uuidv7()"`
	UID          uuid.UUID      `gorm:"column:uid;type:uuid;not null;index"`
	Name         []byte         `gorm:"column:name;type:bytea;not null"`
	EncryptedKey []byte         `gorm:"column:encrypted_key;type:bytea;not null"`
	Groups       []GroupModel   `gorm:"foreignKey:TID;references:ID"`
	CreatedAt    time.Time      `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt    time.Time      `gorm:"column:updated_at;autoUpdateTime"`
	DeletedAt    gorm.DeletedAt `gorm:"column:deleted_at;index"`
}

func (ThemeModel) TableName() string { return "theme" }

type Theme struct {
	Name []byte `json:"name"`
	ID   string `json:"id"`
}

type RequestThemePut struct {
	Data struct {
		Name     []byte `json:"name"`
		UpdateAt string `json:"updateAt"`
	} `json:"data" `
}

type RequestThemePostDefaultGroup struct {
	Name     []byte `json:"name"`
	CreateAt string `json:"createAt"`
	Config   *struct {
		AutoFreezeDays *int `json:"auto_freeze_days"`
	} `json:"config"`
	EncryptedKey []byte `json:"encrypted_key"`
}

type RequestThemePost struct {
	Data struct {
		Name         []byte                       `json:"name"`
		CreateAt     string                       `json:"createAt"`
		DefaultGroup RequestThemePostDefaultGroup `json:"default_group"`
		EncryptedKey []byte                       `json:"encrypted_key"`
	} `json:"data" `
}

// Exported response structs for ListThemes
type DocDetailResponse struct {
	Did      string       `json:"did"`
	Content  m.DocContent `json:"content"`
	CreateAt time.Time    `json:"created_at"`
	UpdateAt time.Time    `json:"updated_at"`
	Legacy   bool         `json:"legacy"` // Used for legacy level bytes logic
}
type GroupDetailResponse struct {
	Gid  string              `json:"gid"`
	Name []byte              `json:"name"`
	Docs []DocDetailResponse `json:"docs"`
}
type ThemeDetailResponse struct {
	Tid       string                `json:"tid"`
	ThemeName []byte                `json:"theme_name"`
	Groups    []GroupDetailResponse `json:"groups"`
}

func ThemesGet(uid string) ([]Theme, error) {
	var results []Theme
	var themes []ThemeModel

	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return nil, err
	}

	if err := DB.Where("uid = ?", uidUUID).Find(&themes).Error; err != nil {
		log.Error(err)
		return nil, err
	}

	for _, t := range themes {
		results = append(results, Theme{Name: t.Name, ID: t.ID.String()})
	}
	return results, nil
}

func ThemesGetAndDocs(uid string, hasID bool) ([]ThemeDetailResponse, error) {
	return themesGetAndDocsInternal(uid)
}

func ThemesGetAndDocsDetail(uid string, hasID bool) ([]ThemeDetailResponse, error) {
	return themesGetAndDocsInternal(uid)
}

func themesGetAndDocsInternal(uid string) ([]ThemeDetailResponse, error) {
	var themes []ThemeModel

	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return nil, err
	}

	err = DB.Preload("Groups.Docs").Where("uid = ?", uidUUID).Find(&themes).Error
	if err != nil {
		return nil, err
	}

	var response []ThemeDetailResponse

	for _, t := range themes {
		var gList []GroupDetailResponse
		for _, g := range t.Groups {
			var dList []DocDetailResponse
			for _, d := range g.Docs {
				dList = append(dList, DocDetailResponse{
					Did: d.ID.String(),
					Content: m.DocContent{
						Title:  d.Title,
						Rich:   d.Rich,
						Scales: d.Scales,
						Level:  d.Level,
					},
					CreateAt: d.CreatedAt,
					UpdateAt: d.UpdatedAt,
					Legacy:   false,
				})
			}
			gList = append(gList, GroupDetailResponse{
				Gid:  g.ID.String(),
				Name: g.Name,
				Docs: dList,
			})
		}

		response = append(response, ThemeDetailResponse{
			Tid:       t.ID.String(),
			ThemeName: t.Name,
			Groups:    gList,
		})
	}

	return response, nil
}

func ThemeCreate(uid string, req *RequestThemePost) (string, error) {
	var tid uuid.UUID
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return "", err
	}
	parsedTime, _ := time.Parse("2006-01-02 15:04:05", req.Data.CreateAt)
	if parsedTime.IsZero() {
		parsedTime = time.Now()
	}

	theme := ThemeModel{
		UID:          uidUUID,
		Name:         req.Data.Name,
		EncryptedKey: req.Data.EncryptedKey,
		CreatedAt:    parsedTime,
		UpdatedAt:    parsedTime,
	}

	if err := DB.Create(&theme).Error; err != nil {
		return "", err
	}
	tid = theme.ID
	return tid.String(), nil
}

func ThemeUpdate(tid string, req *RequestThemePut) error {
	tidUUID, err := uuid.Parse(tid)
	if err != nil {
		return err
	}
	updates := map[string]interface{}{}
	if req.Data.Name != nil {
		updates["name"] = req.Data.Name
	}
	if req.Data.UpdateAt != "" {
		if t, err := time.Parse("2006-01-02 15:04:05", req.Data.UpdateAt); err == nil {
			updates["updated_at"] = t
		}
	}

	if len(updates) > 0 {
		return DB.Model(&ThemeModel{}).Where("id = ?", tidUUID).Updates(updates).Error
	}
	return nil
}

func ThemeDelete(tid string) error {
	tidUUID, err := uuid.Parse(tid)
	if err != nil {
		return err
	}
	return DB.Where("id = ?", tidUUID).Delete(&ThemeModel{}).Error
}
