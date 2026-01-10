package model

import (
	"encoding/json"
	"time"
)

type DocContent struct {
	Title []byte `json:"title"`
	// Legacy rich text payload (deprecated).
	Rich []byte `json:"rich,omitempty"`
	// Encrypted scales payload (JSON string bytes encrypted on client).
	Scales []byte `json:"scales,omitempty"`
	Level  []byte `json:"level,omitempty"`
}

type Doc struct {
	Content  DocContent `json:"content"`
	CreateAt time.Time  `json:"created_at"`
	UpdateAt time.Time  `json:"updated_at"`
	Config   *DocConfig `json:"config,omitempty"`
	ID       string     `json:"id"`
	// OID removed
	LegacyLevel int32 `json:"-"`
}

// MarshalJSON 自定义 JSON 序列化,将时间格式化为字符串
func (d Doc) MarshalJSON() ([]byte, error) {
	type Alias Doc
	return json.Marshal(&struct {
		CreateAt string `json:"created_at"`
		UpdateAt string `json:"updated_at"`
		*Alias
	}{
		CreateAt: d.CreateAt.Format("2006-01-02 15:04:05"),
		UpdateAt: d.UpdateAt.Format("2006-01-02 15:04:05"),
		Alias:    (*Alias)(&d),
	})
}

// UnmarshalJSON 自定义 JSON 反序列化,解析时间字符串
func (d *Doc) UnmarshalJSON(data []byte) error {
	type Alias Doc
	aux := &struct {
		CreateAt string `json:"created_at"`
		UpdateAt string `json:"updated_at"`
		*Alias
	}{
		Alias: (*Alias)(d),
	}

	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	// 解析时间字符串
	createAt, err := time.Parse("2006-01-02 15:04:05", aux.CreateAt)
	if err != nil {
		return err
	}
	updateAt, err := time.Parse("2006-01-02 15:04:05", aux.UpdateAt)
	if err != nil {
		return err
	}

	d.CreateAt = createAt
	d.UpdateAt = updateAt

	return nil
}

type Group struct {
	Name     []byte      `json:"name"`
	ID       string      `json:"id"`
	CreateAt string      `json:"created_at"`
	UpdateAt string      `json:"updated_at"`
	OverAt   string      `json:"over_at,omitempty"`
	Config   GroupConfig `json:"config"`
}
type GroupAndDocs struct {
	GID      string      `json:"gid"`
	Name     []byte      `json:"name"` // 来自 A 集合的 name 字段
	Docs     []Doc       `json:"docs"` // 关联查询到的 B 集合印迹数组
	Default  bool        `json:"default"`
	CreateAt string      `json:"created_at"`
	UpdateAt string      `json:"updated_at"`
	OverAt   string      `json:"over_at,omitempty"`
	Config   GroupConfig `json:"group_config"`
}
type GroupConfig struct {
	Levels         []bool `json:"levels"`
	View_type      int    `json:"view_type"`
	Sort_type      int    `json:"sort_type"`
	AutoFreezeDays int    `json:"auto_freeze_days"`
}

type DocConfig struct {
	IsShowTool      bool `json:"is_show_tool"`
	DisplayPriority int  `json:"display_priority"`
}
