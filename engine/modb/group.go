package modb

import (
	"context"
	"sys"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type Group struct {
	Name     string `json:"name" bson:"name"`
	ID       string `json:"id" bson:"gid"`
	CRTime   string `json:"crtime" bson:"crtime"`
	UPTime   string `json:"uptime" bson:"uptime"`
	OverTime string `json:"overtime" bson:"overtime"`
}

type RequestGroupPost struct {
	Data struct {
		Name     string `json:"name"`
		CRTime   string `json:"crtime"`
		UPTime   string `json:"uptime"`
		OverTime string `json:"overtime"`
	} `json:"data"`
}
type RequestGroupPut struct {
	Data struct {
		Name     string `json:"name"`
		UPTime   string `json:"uptime"`
		OverTime string `json:"overtime"`
	} `json:"data"`
}

func GroupsGet(toid primitive.ObjectID) ([]Group, error) {
	var results []Group

	filter := bson.D{
		{Key: "_toid", Value: toid},
	}

	cursor, err := db.Collection("group").Find(context.TODO(), filter)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	for cursor.Next(context.TODO()) {
		var m bson.M
		err := cursor.Decode(&m)
		if err != nil {
			log.Error(err)
			return nil, err
		}
		results = append(results, Group{
			ID:       m["gid"].(string),
			Name:     m["name"].(string),
			CRTime:   m["crtime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
			UPTime:   m["uptime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
			OverTime: m["overtime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
		})
	}

	if err := cursor.Err(); err != nil {
		log.Error(err)

		return nil, err
	}

	return results, nil
}
func GroupGet(toid primitive.ObjectID, goid primitive.ObjectID) (Group, error) {

	var response Group
	var m bson.M

	filter := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "_id", Value: goid},
	}

	err := db.Collection("group").FindOne(context.TODO(), filter).Decode(&m)
	if err != nil {
		return Group{}, err
	}
	response.ID = m["gid"].(string)
	response.Name = m["name"].(string)
	response.CRTime = m["crtime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05")
	response.UPTime = m["uptime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05")
	response.OverTime = m["overtime"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05")

	return response, nil
}
func GroupGetAndDocDetail(toid primitive.ObjectID, goid primitive.ObjectID) (any, error) {

	type doc struct {
		Title     string             `json:"title" bson:"title"`
		Content   string             `json:"content" bson:"content"`
		PlainText string             `json:"plain_text" bson:"plain_text"`
		Level     int                `json:"level" bson:"level"`
		CRTime    primitive.DateTime `json:"crtime"`
		UPTime    primitive.DateTime `json:"uptime"`
		Config    *config            `json:"config,omitempty" bson:"config"`
		ID        string             `json:"did" bson:"did"`
	}

	type groups struct {
		GID  string `json:"gid" bson:"gid"`
		Name string `json:"name" bson:"name,omitempty"` // 来自 A 集合的 name 字段
		Docs []doc  `json:"docs" bson:"docs,omitempty"` // 关联查询到的 B 集合印迹数组
	}

	// 构建聚合管道
	pipeline := mongo.Pipeline{
		bson.D{ // 阶段一：$match - 筛选 A 集合，找到指定 gid 的印迹
			{Key: "$match", Value: bson.D{{Key: "_id", Value: goid}}},
		},
		bson.D{ // 阶段二：$lookup - 关联查询 B 集合
			{Key: "$lookup", Value: bson.D{
				{Key: "from", Value: "doc"},           // 要关联的集合是 'B'
				{Key: "localField", Value: "_id"},     // A 集合的 _id 字段作为本地连接字段
				{Key: "foreignField", Value: "_goid"}, // B 集合的 _goid 字段作为外地连接字段
				{Key: "as", Value: "docs"},            // 将匹配到的 B 集合印迹放入名为 'docs' 的数组字段
			}},
		},
		bson.D{ // 阶段三：$project - 重塑输出印迹结构
			{Key: "$project", Value: bson.D{
				{Key: "gid", Value: 1},  // 排除输出结果中的 _id 字段
				{Key: "name", Value: 1}, // 从 A 集合中提取 name 字段，并重命名为 "name_from_A" (假设 A 集合有 name 字段)
				{Key: "docs", Value: 1}, // 保留关联查询到的 B 集合印迹数组，命名为 "docs"
			}},
		},
	}

	// 执行聚合查询
	cursor, err := db.Collection("group").Aggregate(context.TODO(), pipeline)
	if err != nil {
		log.Error(err)
		return nil, err
	}
	defer cursor.Close(context.TODO())

	// 遍历查询结果
	var results []groups
	if err := cursor.All(context.TODO(), &results); err != nil {
		log.Error(err)
		return nil, err
	}
	return results[0], nil

}
func GroupPost(toid primitive.ObjectID, req *RequestGroupPost) (string, error) {

	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: req.Data.Name},
		{Key: "crtime", Value: sys.StringtoTime(req.Data.CRTime)},
		{Key: "uptime", Value: sys.StringtoTime(req.Data.UPTime)},
		{Key: "overtime", Value: sys.StringtoTime(req.Data.OverTime)},
		{Key: "gid", Value: gid},
	}

	_, err := db.Collection("group").InsertOne(context.TODO(), data)
	if err != nil {
		return "", err
	}

	return gid, nil
}
func GroupPut(toid primitive.ObjectID, goid primitive.ObjectID, req *RequestGroupPut) error {

	filter := bson.M{
		"_toid": toid,
		"_id":   goid,
	}

	m := bson.M{}

	if (*req).Data.Name != "" {
		m["name"] = (*req).Data.Name
	}

	if (*req).Data.UPTime != "" {
		m["uptime"] = sys.StringtoTime((*req).Data.UPTime)
	}

	if (*req).Data.OverTime != "" {
		m["overtime"] = sys.StringtoTime((*req).Data.OverTime)
	}

	_, err := db.Collection("group").UpdateOne(
		context.TODO(),
		filter,
		bson.M{
			"$set": m,
		},
		nil,
	)
	return err
}
func GroupCreateDefault(toid primitive.ObjectID, gd RequestThemePostDefaultGroup) (string, error) {

	gid := sys.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: gd.Name},
		{Key: "gid", Value: gid},
		{Key: "crtime", Value: sys.StringtoTime(gd.CRTime)},
		{Key: "uptime", Value: sys.StringtoTime(gd.CRTime)},
		{Key: "overtime", Value: sys.StringtoTime(gd.OverTime)},
		{Key: "default", Value: true},
	}

	_, err := db.Collection("group").InsertOne(context.TODO(), data)

	if err != nil {
		return "", err
	}
	return gid, nil
}

// 说明 删除一个分组和所有日志
func GroupDeleteOne(toid primitive.ObjectID, goid primitive.ObjectID) error {
	filter := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "_id", Value: goid},
	}

	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)

	return err
}

// 说明 根据goid删除一个分组
func GroupDeleteFromGOID(goid primitive.ObjectID) error {
	filter := bson.M{
		"_id": goid,
	}
	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)
	return err
}
