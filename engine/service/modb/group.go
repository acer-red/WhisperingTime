package modb

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"time"

	"github.com/tengfei-xy/go-log"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/gridfs"
	"go.mongodb.org/mongo-driver/mongo/options"

	ml "github.com/acer-red/whisperingtime/engine/model"
	"github.com/acer-red/whisperingtime/engine/util"
)

type RequestGroupPost struct {
	Data struct {
		Name     []byte `json:"name"`
		CreateAt string `json:"createAt"`
		UpdateAt string `json:"updateAt"`
		Config   *struct {
			AutoFreezeDays *int `json:"auto_freeze_days"`
		} `json:"config"`
	} `json:"data"`
}
type RequestGroupPut struct {
	Data struct {
		Name     *[]byte `json:"name"`
		UpdateAt *string `json:"updateAt"`
		OverAt   *string `json:"overAt"`
		Config   *struct {
			Levels         *[]bool `json:"levels"`
			View_type      *int    `json:"view_type"`
			Sort_type      *int    `json:"sort_type"`
			AutoFreezeDays *int    `json:"auto_freeze_days"`
		} `json:"config"`
	} `json:"data"`
}

func GroupsGet(toid primitive.ObjectID) ([]ml.Group, error) {
	var results []ml.Group

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
		config := NewGroupConfig()

		if ms, ok := m["config"].(bson.M); ok {

			if ret, o := ms["levels"].(primitive.A); o {
				if len(ret) == 5 {
					config.Levels = []bool{ret[0].(bool), ret[1].(bool), ret[2].(bool), ret[3].(bool), ret[4].(bool)}
				}
			}

			if ret, o := toInt(ms["view_type"]); o {
				config.View_type = ret
			}
			if ret, o := toInt(ms["sort_type"]); o {
				config.Sort_type = ret
			}
			if ret, o := toInt(ms["auto_freeze_days"]); o {
				config.AutoFreezeDays = ret
			}

		} else {
			log.Error("config is not bson.M")
		}
		var overAt string
		switch val := m["overAt"].(type) {
		case primitive.DateTime:
			overAt = val.Time().Format("2006-01-02 15:04:05")
		case time.Time:
			overAt = val.Format("2006-01-02 15:04:05")
		}

		results = append(results, ml.Group{
			ID:       m["gid"].(string),
			Name:     bytesField(m["name"]),
			CreateAt: m["createAt"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
			UpdateAt: m["updateAt"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05"),
			OverAt:   overAt,
			Config:   config,
		})
	}

	if err := cursor.Err(); err != nil {
		log.Error(err)

		return nil, err
	}

	return results, nil
}
func GroupGet(toid primitive.ObjectID, goid primitive.ObjectID) (ml.Group, error) {

	var res ml.Group
	var m bson.M

	filter := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "_id", Value: goid},
	}

	err := db.Collection("group").FindOne(context.TODO(), filter).Decode(&m)
	if err != nil {
		return ml.Group{}, err
	}
	res.ID = m["gid"].(string)
	res.Name = bytesField(m["name"])
	res.CreateAt = m["createAt"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05")
	res.UpdateAt = m["updateAt"].(primitive.DateTime).Time().Format("2006-01-02 15:04:05")
	if val, ok := m["overAt"].(primitive.DateTime); ok {
		res.OverAt = val.Time().Format("2006-01-02 15:04:05")
	}

	res.Config = NewGroupConfig()

	if config, ok := m["config"].(bson.M); ok {
		res.Config.Levels = config["levels"].([]bool)
		if val, ok := toInt(config["view_type"]); ok {
			res.Config.View_type = val
		}
		if val, ok := toInt(config["sort_type"]); ok {
			res.Config.Sort_type = val
		}
		if val, ok := toInt(config["auto_freeze_days"]); ok {
			res.Config.AutoFreezeDays = val
		}
	}

	return res, nil
}
func GroupGetAndDocDetail(toid primitive.ObjectID, goid primitive.ObjectID) (ml.GroupAndDocs, error) {

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
		return ml.GroupAndDocs{}, err
	}
	defer cursor.Close(context.TODO())

	// 遍历查询结果
	var results []ml.GroupAndDocs
	if err := cursor.All(context.TODO(), &results); err != nil {
		log.Error(err)
		return ml.GroupAndDocs{}, err
	}
	return results[0], nil

}
func GroupPost(toid primitive.ObjectID, req *RequestGroupPost) (string, error) {

	gid := util.CreateUUID()
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: req.Data.Name},
		{Key: "createAt", Value: util.StringtoTime(req.Data.CreateAt)},
		{Key: "updateAt", Value: util.StringtoTime(req.Data.UpdateAt)},
		{Key: "gid", Value: gid},
		{Key: "config", Value: buildConfig(req.Data.Config)},
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

	if req.Data.Name != nil {
		m["name"] = *req.Data.Name
	}

	if (*req).Data.OverAt != nil {
		m["overAt"] = util.StringtoTime(*(*req).Data.OverAt)
	}

	if req.Data.Config != nil {

		if req.Data.Config.Levels != nil {
			m["config.levels"] = req.Data.Config.Levels
		}
		if req.Data.Config.View_type != nil {
			m["config.view_type"] = req.Data.Config.View_type
		}
		if req.Data.Config.Sort_type != nil {
			m["config.sort_type"] = req.Data.Config.Sort_type
		}
		if req.Data.Config.AutoFreezeDays != nil {
			m["config.auto_freeze_days"] = req.Data.Config.AutoFreezeDays
		}
	}

	if len(m) > 0 {
		if _, err := db.Collection("group").UpdateOne(
			context.TODO(),
			filter,
			bson.M{
				"$set": m,
			},
			nil,
		); err != nil {
			return err
		}
	}

	return refreshGroupUpdateAt(goid, req.Data.OverAt == nil)
}
func GroupCreateDefault(toid primitive.ObjectID, gd RequestThemePostDefaultGroup) (string, error) {

	gid := util.CreateUUID()
	config := buildConfig(gd.Config)
	data := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: gd.Name},
		{Key: "gid", Value: gid},
		{Key: "createAt", Value: util.StringtoTime(gd.CreateAt)},
		{Key: "updateAt", Value: util.StringtoTime(gd.CreateAt)},
		{Key: "default", Value: true},
		{Key: "config", Value: config},
	}

	_, err := db.Collection("group").InsertOne(context.TODO(), data)

	if err != nil {
		return "", err
	}
	return gid, nil
}

// GroupDeleteOne 删除一个分组和所有日志
func GroupDeleteOne(toid primitive.ObjectID, goid primitive.ObjectID) error {
	filter := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "_id", Value: goid},
	}

	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)

	return err
}

// GroupDeleteFromGOID 根据goid删除一个分组
func GroupDeleteFromGOID(goid primitive.ObjectID) error {
	filter := bson.M{
		"_id": goid,
	}
	_, err := db.Collection("group").DeleteOne(context.TODO(), filter, nil)
	return err
}

// GroupExportConfig 导出分组配置
func GroupExportConfig(uoid, toid, goid primitive.ObjectID) (string, error) {

	bgjoid, taskID, err := createBGJob(uoid, JobTypeExportGroupConfig, JobPriority0, "导出分组配置")
	if err != nil {
		return "", err
	}

	go CountinueExportConfig(BGJobOID{
		_ID: bgjoid,
	}, uoid, toid, goid)

	return taskID, nil
}
func CountinueExportConfig(id BGJobOID, uoid, toid, goid primitive.ObjectID) error {
	id.SetJobRunning()
	l, err := GroupGetAndDocDetail(toid, goid)
	if err != nil {
		id.SetError(JobError{
			Code:    1,
			Message: err.Error(),
		},
		)
		return err
	}
	oids := make([]primitive.ObjectID, 0)
	for _, doc := range l.Docs {
		oids = append(oids, doc.OID)
	}
	// match := bson.D{
	// 	{Key: "$match", Value: bson.D{
	// 		{Key: "_id", Value: bson.M{"$in": oids}}, //fs.files的_id
	// 		{Key: "metadata.uoid", Value: bson.M{
	// 			"$exists": true,
	// 			"$ne":     nil,
	// 		}},
	// 	}},
	// }
	match := bson.D{
		{Key: "$match", Value: bson.D{
			{Key: "_id", Value: bson.M{"$in": oids}},
			{Key: "metadata.uoid", Value: bson.M{
				"$exists": true,
				"$ne":     nil,
			}},
		}},
	}

	// 3. 构建 $group 阶段
	group := bson.D{
		{Key: "$group", Value: bson.D{
			{Key: "_id", Value: "uoid"},
		}},
	}

	// 4. (可选) 构建 $project 阶段
	project := bson.D{
		{Key: "$project", Value: bson.D{
			{Key: "_id", Value: 0},
			{Key: "filename", Value: 1},
			{Key: "foid", Value: "$_id"}, //添加一个新字段 "foid"，其值来源于输入的 "_id" 字段
		}},
	}
	// 5. 执行聚合查询
	pipeline := mongo.Pipeline{match, group, project}
	cursor, err := db.Collection("fs.files").Aggregate(context.TODO(), pipeline)
	if err != nil {
		log.Error(err)
		id.SetError(JobError{
			Code:    1,
			Message: err.Error(),
		},
		)
		return err
	}
	defer cursor.Close(context.TODO())

	// 6. 处理结果
	var results []bson.M
	if err = cursor.All(context.TODO(), &results); err != nil {
		log.Error(err)
		id.SetError(JobError{
			Code:    1,
			Message: err.Error(),
		},
		)
		return err
	}
	base := `/users/tengfei/Documents/source/project/acer/tmp/store/`

	base = filepath.Join(base, "枫迹")
	groupName := base64.RawURLEncoding.EncodeToString(l.Name)

	// 数据导出的文件名
	outZipFilename := fmt.Sprintf("分组配置-%s-%s.zip", groupName, util.YYYYMMDDhhmmss())
	// 数据导出的路径

	outZipPath := filepath.Join(base, outZipFilename)

	log.Infof("路径:%s 输出文件名:%s ", outZipPath, outZipFilename)

	configFilename := filepath.Join(base, `config.json`)

	var dir string
	// 只有在 results 不为空时才创建 images 目录并处理图片
	if len(results) > 0 {
		dir = filepath.Join(base, "images")
		if err := os.MkdirAll(dir, 0777); err != nil {
			log.Error(err)
			id.SetError(JobError{Code: 1,
				Message: err.Error()})
			return err
		}
	}

	for _, result := range results {
		foid, _ := result["foid"].(primitive.ObjectID)
		filename, _ := result["filename"].(string)
		log.Infof("导出分组印迹，发现文件: %s", filename)

		bucket, err := gridfs.NewBucket(db)
		if err != nil {
			log.Error(err)
			id.SetError(JobError{
				Code:    1,
				Message: err.Error(),
			},
			)
			return err
		}
		downloadStreamByID, err := bucket.OpenDownloadStream(foid) // 使用文件 ID 下载
		if err != nil {
			panic(err)
		}

		var downloadBuffer bytes.Buffer
		if _, err := io.Copy(&downloadBuffer, downloadStreamByID); err != nil {

			downloadStreamByID.Close()
			panic(err)
		}
		// 将下载的文件存放在goid/下
		filename = filepath.Join(dir, filename)

		if err := os.WriteFile(filename, downloadBuffer.Bytes(), 0644); err != nil {
			downloadStreamByID.Close()
			log.Error(err)
			id.SetError(JobError{
				Code:    1,
				Message: err.Error(),
			},
			)
			return err
		}
		log.Infof("导出分组配置， 图片下载完成 %s", filename)
		downloadStreamByID.Close()
	}
	d, err := json.Marshal(&l)
	if err != nil {
		log.Error(err)
		id.SetError(JobError{
			Code:    1,
			Message: err.Error(),
		})
		return err
	}
	if err := os.WriteFile(configFilename, d, 0644); err != nil {
		log.Error(err)
		id.SetError(JobError{
			Code:    1,
			Message: err.Error(),
		})
		return err
	}
	log.Infof("配置写入完成 %s", configFilename)

	// 如果有图片，压缩 images 目录和配置文件；否则只压缩配置文件
	if len(results) > 0 {
		util.ZipDirectory(dir, outZipPath, configFilename)
	} else {
		util.ZipDirectory(filepath.Dir(configFilename), outZipPath)
	}

	id.SetJobCompleted(bson.M{"filename": outZipPath})
	log.Infof("后台任务完成 %s", id._ID.Hex())
	return nil
}

// ExportAllThemesConfig 导出当前用户的全部主题和分组配置
func ExportAllThemesConfig(uoid primitive.ObjectID) (string, error) {

	bgjoid, taskID, err := createBGJob(uoid, JobTypeExportAllConfig, JobPriority0, "导出全部主题配置")
	if err != nil {
		return "", err
	}

	go continueExportAllThemesConfig(BGJobOID{
		_ID: bgjoid,
	}, uoid)

	return taskID, nil
}

type themeExport struct {
	Tid    string             `json:"tid" bson:"tid"`
	Name   []byte             `json:"name" bson:"name"`
	Groups []ml.GroupAndDocs  `json:"groups"`
	OID    primitive.ObjectID `json:"-" bson:"_id"`
}

func loadAllThemesWithGroups(uoid primitive.ObjectID) ([]themeExport, []primitive.ObjectID, error) {
	ctx := context.TODO()
	cursor, err := db.Collection("theme").Find(ctx, bson.M{"_uid": uoid})
	if err != nil {
		return nil, nil, err
	}
	defer cursor.Close(ctx)

	themes := make([]themeExport, 0)
	docIDs := make([]primitive.ObjectID, 0)
	docIDSet := make(map[primitive.ObjectID]struct{})

	for cursor.Next(ctx) {
		var t themeExport
		if err := cursor.Decode(&t); err != nil {
			return nil, nil, err
		}

		goids, err := GetGOIDsFromTOID(t.OID)
		if err != nil {
			return nil, nil, err
		}

		for _, goid := range goids {
			group, err := GroupGetAndDocDetail(t.OID, goid)
			if err != nil {
				return nil, nil, err
			}
			t.Groups = append(t.Groups, group)
			for _, doc := range group.Docs {
				if doc.OID.IsZero() {
					continue
				}
				if _, ok := docIDSet[doc.OID]; ok {
					continue
				}
				docIDSet[doc.OID] = struct{}{}
				docIDs = append(docIDs, doc.OID)
			}
		}

		themes = append(themes, t)
	}

	if err := cursor.Err(); err != nil {
		return nil, nil, err
	}

	return themes, docIDs, nil
}

func continueExportAllThemesConfig(id BGJobOID, uoid primitive.ObjectID) error {
	id.SetJobRunning()

	themes, docIDs, err := loadAllThemesWithGroups(uoid)
	if err != nil {
		id.SetError(JobError{Code: 1, Message: err.Error()})
		return err
	}

	if len(themes) == 0 {
		err = fmt.Errorf("没有可导出的主题")
		id.SetError(JobError{Code: 1, Message: err.Error()})
		return err
	}

	base := `/users/tengfei/Documents/source/project/acer/tmp/store/`

	base = filepath.Join(base, "枫迹")
	if err := os.MkdirAll(base, 0777); err != nil {
		id.SetError(JobError{Code: 1, Message: err.Error()})
		return err
	}

	workdir := filepath.Join(base, "export_all_"+util.CreateUUID())
	if err := os.MkdirAll(workdir, 0777); err != nil {
		id.SetError(JobError{Code: 1, Message: err.Error()})
		return err
	}
	defer os.RemoveAll(workdir)

	configFilename := filepath.Join(workdir, `config.json`)

	if len(docIDs) > 0 {
		if err := exportImagesForDocs(docIDs, workdir); err != nil {
			id.SetError(JobError{Code: 1, Message: err.Error()})
			return err
		}
	}

	data, err := json.Marshal(&themes)
	if err != nil {
		id.SetError(JobError{Code: 1, Message: err.Error()})
		return err
	}

	if err := os.WriteFile(configFilename, data, 0644); err != nil {
		id.SetError(JobError{Code: 1, Message: err.Error()})
		return err
	}

	outZipFilename := fmt.Sprintf("全部主题配置-%s.zip", util.YYYYMMDDhhmmss())
	outZipPath := filepath.Join(base, outZipFilename)

	util.ZipDirectory(workdir, outZipPath)

	id.SetJobCompleted(bson.M{"filename": outZipPath})
	log.Infof("后台任务完成 %s", id._ID.Hex())
	return nil
}

func exportImagesForDocs(docIDs []primitive.ObjectID, workdir string) error {
	ctx := context.TODO()
	filter := bson.M{
		"_id":           bson.M{"$in": docIDs},
		"metadata.uoid": bson.M{"$exists": true, "$ne": nil},
	}

	cursor, err := db.Collection("fs.files").Find(ctx, filter)
	if err != nil {
		return err
	}
	defer cursor.Close(ctx)

	imagesDir := filepath.Join(workdir, "images")
	if err := os.MkdirAll(imagesDir, 0777); err != nil {
		return err
	}

	bucket, err := gridfs.NewBucket(db)
	if err != nil {
		return err
	}

	for cursor.Next(ctx) {
		var file struct {
			ID       primitive.ObjectID `bson:"_id"`
			Filename string             `bson:"filename"`
		}
		if err := cursor.Decode(&file); err != nil {
			return err
		}

		downloadStream, err := bucket.OpenDownloadStream(file.ID)
		if err != nil {
			return err
		}

		var buf bytes.Buffer
		if _, err := io.Copy(&buf, downloadStream); err != nil {
			downloadStream.Close()
			return err
		}
		if err := downloadStream.Close(); err != nil {
			return err
		}

		imagePath := filepath.Join(imagesDir, file.Filename)
		if err := os.WriteFile(imagePath, buf.Bytes(), 0644); err != nil {
			return err
		}
		log.Infof("导出图片: %s", imagePath)
	}

	return cursor.Err()
}

func NewGroupConfig() ml.GroupConfig {
	return ml.GroupConfig{
		Levels:         []bool{true, true, true, true, true},
		View_type:      0,
		Sort_type:      0,
		AutoFreezeDays: 30,
	}
}

func buildConfig(cfg *struct {
	AutoFreezeDays *int `json:"auto_freeze_days"`
}) ml.GroupConfig {
	config := NewGroupConfig()
	if cfg != nil && cfg.AutoFreezeDays != nil {
		config.AutoFreezeDays = *cfg.AutoFreezeDays
	}
	return config
}

func toInt(v any) (int, bool) {
	switch val := v.(type) {
	case int:
		return val, true
	case int32:
		return int(val), true
	case int64:
		return int(val), true
	case float64:
		return int(val), true
	default:
		return 0, false
	}
}

func bytesField(v any) []byte {
	switch val := v.(type) {
	case []byte:
		return val
	case primitive.Binary:
		return val.Data
	case string:
		return []byte(val)
	default:
		return []byte{}
	}
}

// refreshGroupUpdateAt bumps updateAt and optionally clears manual buffer state when it is still active.
func refreshGroupUpdateAt(goid primitive.ObjectID, clearBuffer bool) error {
	filter := bson.M{"_id": goid}

	update := bson.M{
		"$set": bson.M{
			"updateAt": primitive.NewDateTimeFromTime(time.Now()),
		},
	}

	if clearBuffer {
		var g struct {
			OverAt *primitive.DateTime `bson:"overAt"`
		}
		if err := db.Collection("group").FindOne(context.TODO(), filter).Decode(&g); err != nil {
			if err == mongo.ErrNoDocuments {
				return nil
			}
			return err
		}
		if g.OverAt != nil && g.OverAt.Time().After(time.Now()) {
			update["$unset"] = bson.M{"overAt": ""}
		}
	}

	_, err := db.Collection("group").UpdateOne(context.TODO(), filter, update)
	return err
}

// GroupImportConfig 导入分组配置
func GroupImportConfig(uoid, toid primitive.ObjectID, fileHeader *multipart.FileHeader) error {
	// 创建临时目录
	tmpDir := filepath.Join(os.TempDir(), "whisperingtime_import_"+util.CreateUUID())
	if err := os.MkdirAll(tmpDir, 0755); err != nil {
		return fmt.Errorf("创建临时目录失败: %w", err)
	}
	defer os.RemoveAll(tmpDir) // 清理临时目录

	// 保存上传的zip文件
	zipPath := filepath.Join(tmpDir, fileHeader.Filename)
	file, err := fileHeader.Open()
	if err != nil {
		return fmt.Errorf("打开上传文件失败: %w", err)
	}
	defer file.Close()

	out, err := os.Create(zipPath)
	if err != nil {
		return fmt.Errorf("创建临时文件失败: %w", err)
	}
	defer out.Close()

	if _, err := io.Copy(out, file); err != nil {
		return fmt.Errorf("保存文件失败: %w", err)
	}
	out.Close() // 关闭文件以便解压

	// 解压zip文件
	extractDir := filepath.Join(tmpDir, "extracted")
	extractedFiles, err := util.UnzipFile(zipPath, extractDir)
	if err != nil {
		return fmt.Errorf("解压文件失败: %w", err)
	}

	// 从解压的文件列表中查找config.json
	var configPath string
	for _, filePath := range extractedFiles {
		if filepath.Base(filePath) == "config.json" {
			configPath = filePath
			break
		}
	}

	if configPath == "" {
		return fmt.Errorf("配置文件 config.json 不存在")
	}

	// 读取并解析config.json
	configData, err := os.ReadFile(configPath)
	if err != nil {
		return fmt.Errorf("读取配置文件失败: %w", err)
	}

	var groupAndDocs ml.GroupAndDocs
	if err := json.Unmarshal(configData, &groupAndDocs); err != nil {
		return fmt.Errorf("解析配置文件失败: %w", err)
	}

	// 开始导入数据到MongoDB
	// 1. 创建或更新分组
	gid := groupAndDocs.GID
	if gid == "" {
		gid = util.CreateUUID()
	}

	// 检查分组是否已存在
	filter := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "gid", Value: gid},
	}

	var existingGroup bson.M
	err = db.Collection("group").FindOne(context.TODO(), filter).Decode(&existingGroup)

	groupData := bson.D{
		{Key: "_toid", Value: toid},
		{Key: "name", Value: groupAndDocs.Name},
		{Key: "gid", Value: gid},
		{Key: "updateAt", Value: primitive.NewDateTimeFromTime(time.Now())},
		{Key: "config", Value: groupAndDocs.Config},
	}

	if err == mongo.ErrNoDocuments {
		// 分组不存在，创建新分组
		groupData = append(groupData,
			bson.E{Key: "createAt", Value: primitive.NewDateTimeFromTime(time.Now())},
		)
		_, err = db.Collection("group").InsertOne(context.TODO(), groupData)
		if err != nil {
			return fmt.Errorf("创建分组失败: %w", err)
		}
	} else if err != nil {
		return fmt.Errorf("查询分组失败: %w", err)
	} else {
		// 分组已存在，更新分组信息
		update := bson.M{
			"$set": bson.M{
				"name":     groupAndDocs.Name,
				"updateAt": primitive.NewDateTimeFromTime(time.Now()),
				"config":   groupAndDocs.Config,
			},
		}
		_, err = db.Collection("group").UpdateOne(context.TODO(), filter, update)
		if err != nil {
			return fmt.Errorf("更新分组失败: %w", err)
		}
	}

	// 2. 导入文档和图片
	// 获取分组的ObjectID
	var goidDoc bson.M
	err = db.Collection("group").FindOne(context.TODO(), filter).Decode(&goidDoc)
	if err != nil {
		return fmt.Errorf("获取分组ID失败: %w", err)
	}
	goid := goidDoc["_id"].(primitive.ObjectID)

	// 处理images目录（如果存在）
	// 从解压的文件列表中筛选出images目录下的文件
	var imageFiles []string
	for _, filePath := range extractedFiles {
		// 检查文件是否在images目录下
		relPath, err := filepath.Rel(extractDir, filePath)
		if err != nil {
			continue
		}
		if filepath.HasPrefix(relPath, "images"+string(os.PathSeparator)) ||
			filepath.HasPrefix(relPath, filepath.Join("images")) {
			imageFiles = append(imageFiles, filePath)
		}
	}

	imageMap := make(map[string]primitive.ObjectID) // 原文件名 -> 新的GridFS文件ID

	if len(imageFiles) > 0 {
		// 有图片文件，上传到GridFS
		bucket, err := gridfs.NewBucket(db)
		if err != nil {
			return fmt.Errorf("创建GridFS bucket失败: %w", err)
		}

		for _, imagePath := range imageFiles {
			imageData, err := os.ReadFile(imagePath)
			if err != nil {
				log.Error(fmt.Errorf("读取图片文件失败 %s: %w", imagePath, err))
				continue
			}

			fileName := filepath.Base(imagePath)

			// 上传到GridFS
			uploadStream, err := bucket.OpenUploadStream(fileName, &options.UploadOptions{
				Metadata: bson.M{
					"uoid": uoid,
				},
			})
			if err != nil {
				log.Error(fmt.Errorf("创建上传流失败 %s: %w", fileName, err))
				continue
			}

			if _, err := uploadStream.Write(imageData); err != nil {
				uploadStream.Close()
				log.Error(fmt.Errorf("写入图片数据失败 %s: %w", fileName, err))
				continue
			}

			if err := uploadStream.Close(); err != nil {
				log.Error(fmt.Errorf("关闭上传流失败 %s: %w", fileName, err))
				continue
			}

			// 记录文件名和对应的GridFS ID
			imageMap[fileName] = uploadStream.FileID.(primitive.ObjectID)
			log.Infof("成功上传图片: %s -> %s", fileName, uploadStream.FileID)
		}
	}

	// 3. 导入文档数据
	for _, doc := range groupAndDocs.Docs {
		// 生成新的文档ID
		did := util.CreateUUID()

		// 处理文档内容中的图片引用
		// 这里需要根据实际的图片引用格式来替换
		// 假设图片引用格式为某种特定格式，需要替换为新的GridFS ID
		content := doc.Content
		// TODO: 根据实际情况处理图片引用的替换

		docData := bson.D{
			{Key: "_goid", Value: goid},
			{Key: "_toid", Value: toid},
			{Key: "did", Value: did},
			{Key: "content", Value: content},
			{Key: "createAt", Value: primitive.NewDateTimeFromTime(doc.CreateAt)},
			{Key: "updateAt", Value: primitive.NewDateTimeFromTime(time.Now())},
		}

		if doc.Config != nil {
			docData = append(docData, bson.E{Key: "config", Value: doc.Config})
		}

		_, err := db.Collection("doc").InsertOne(context.TODO(), docData)
		if err != nil {
			log.Error(fmt.Errorf("插入文档失败: %w", err))
			continue
		}
		log.Infof("成功导入文档: %s", did)
	}

	log.Info("分组配置导入完成")
	return nil
}
