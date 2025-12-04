package model

import (
	"encoding/json"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Doc struct {
	Title     string             `json:"title" bson:"title"`
	Content   string             `json:"content" bson:"content"`
	PlainText string             `json:"plain_text" bson:"plain_text"`
	Level     int32              `json:"level" bson:"level"`
	CreateAt  time.Time          `json:"createAt" bson:"createAt"`
	UpdateAt  time.Time          `json:"updateAt" bson:"updateAt"`
	Config    *DocConfig         `json:"config,omitempty" bson:"config"`
	ID        string             `json:"id" bson:"did"`
	OID       primitive.ObjectID `json:"-" bson:"_id"`
}

// MarshalJSON 自定义 JSON 序列化,将时间格式化为字符串
func (d Doc) MarshalJSON() ([]byte, error) {
	type Alias Doc
	return json.Marshal(&struct {
		CreateAt string `json:"createAt"`
		UpdateAt string `json:"updateAt"`
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
		CreateAt string `json:"createAt"`
		UpdateAt string `json:"updateAt"`
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
	Name     string      `json:"name" bson:"name"`
	ID       string      `json:"id" bson:"gid"`
	CreateAt string      `json:"createAt" bson:"createAt"`
	UpdateAt string      `json:"updateAt" bson:"updateAt"`
	OverAt   string      `json:"overAt" bson:"overAt"`
	Config   GroupConfig `json:"config"`
}
type GroupAndDocs struct {
	GID      string      `json:"gid" bson:"gid"`
	Name     string      `json:"name" bson:"name,omitempty"` // 来自 A 集合的 name 字段
	Docs     []Doc       `json:"docs" bson:"docs,omitempty"` // 关联查询到的 B 集合印迹数组
	Default  bool        `json:"default" bson:"default,omitempty"`
	CreateAt string      `json:"createAt" bson:"createAt"`
	UpdateAt string      `json:"updateAt" bson:"updateAt"`
	OverAt   string      `json:"overAt" bson:"overAt"`
	Config   GroupConfig `json:"group_config" bson:"group_config"`
}
type GroupConfig struct {
	Is_multi  bool   `json:"is_multi" bson:"is_multi"`
	Is_all    bool   `json:"is_all" bson:"is_all"`
	Levels    []bool `json:"levels" bson:"levels"`
	View_type int    `json:"view_type" bson:"view_type"`
	Sort_type int    `json:"sort_type" bson:"sort_type"`
}

type DocConfig struct {
	IsShowTool bool `json:"is_show_tool" bson:"is_show_tool"`
}
