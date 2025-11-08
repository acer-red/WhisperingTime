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
	CRTime    time.Time          `json:"crtime" bson:"crtime"`
	UPTime    time.Time          `json:"uptime" bson:"uptime"`
	Config    *DocConfig         `json:"config,omitempty" bson:"config"`
	ID        string             `json:"id" bson:"did"`
	OID       primitive.ObjectID `json:"-" bson:"_id"`
}

// MarshalJSON 自定义 JSON 序列化,将时间格式化为字符串
func (d Doc) MarshalJSON() ([]byte, error) {
	type Alias Doc
	return json.Marshal(&struct {
		CRTime string `json:"crtime"`
		UPTime string `json:"uptime"`
		*Alias
	}{
		CRTime: d.CRTime.Format("2006-01-02 15:04:05"),
		UPTime: d.UPTime.Format("2006-01-02 15:04:05"),
		Alias:  (*Alias)(&d),
	})
}

// UnmarshalJSON 自定义 JSON 反序列化,解析时间字符串
func (d *Doc) UnmarshalJSON(data []byte) error {
	type Alias Doc
	aux := &struct {
		CRTime string `json:"crtime"`
		UPTime string `json:"uptime"`
		*Alias
	}{
		Alias: (*Alias)(d),
	}

	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	// 解析时间字符串
	crtime, err := time.Parse("2006-01-02 15:04:05", aux.CRTime)
	if err != nil {
		return err
	}
	uptime, err := time.Parse("2006-01-02 15:04:05", aux.UPTime)
	if err != nil {
		return err
	}

	d.CRTime = crtime
	d.UPTime = uptime

	return nil
}

type Group struct {
	Name     string      `json:"name" bson:"name"`
	ID       string      `json:"id" bson:"gid"`
	CRTime   string      `json:"crtime" bson:"crtime"`
	UPTime   string      `json:"uptime" bson:"uptime"`
	OverTime string      `json:"overtime" bson:"overtime"`
	Config   GroupConfig `json:"config"`
}
type GroupAndDocs struct {
	GID      string      `json:"gid" bson:"gid"`
	Name     string      `json:"name" bson:"name,omitempty"` // 来自 A 集合的 name 字段
	Docs     []Doc       `json:"docs" bson:"docs,omitempty"` // 关联查询到的 B 集合印迹数组
	Default  bool        `json:"default" bson:"default,omitempty"`
	CRTime   string      `json:"crtime" bson:"crtime"`
	UPTime   string      `json:"uptime" bson:"uptime"`
	OverTime bool        `json:"over_time" bson:"over_time"`
	Config   GroupConfig `json:"group_config" bson:"group_config"`
}
type GroupConfig struct {
	IsMulti  bool   `json:"is_multi" bson:"is_multi"`
	IsAll    bool   `json:"is_all" bson:"is_all"`
	Levels   []bool `json:"levels" bson:"levels"`
	ViewType int    `json:"view_type" bson:"view_type"`
}

type DocConfig struct {
	IsShowTool bool `json:"is_show_tool" bson:"is_show_tool"`
}
