package modb

import (
	"context"

	"github.com/tengfei-xy/whisperingtime/engine/sys"

	log "github.com/tengfei-xy/go-log"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"

	m "github.com/tengfei-xy/whisperingtime/engine/model"
)

type Theme struct {
	Name []byte `json:"name" bson:"name"`
	ID   string `json:"id" bson:"tid"`
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
}

type RequestThemePost struct {
	Data struct {
		Name         []byte                       `json:"name"`
		CreateAt     string                       `json:"createAt"`
		DefaultGroup RequestThemePostDefaultGroup `json:"default_group"`
	} `json:"data" `
}

// 根据uoid输出主题的基本结构
func ThemesGet(uoid primitive.ObjectID) ([]Theme, error) {

	var results []Theme

	filter := bson.D{
		{Key: "_uid", Value: uoid},
	}

	cursor, err := db.Collection("theme").Find(context.TODO(), filter)
	if err != nil {
		log.Error(err)
		return nil, err
	}

	for cursor.Next(context.TODO()) {
		var m bson.M
		if err := cursor.Decode(&m); err != nil {
			log.Error(err)
			return nil, err
		}
		name := bytesField(m["name"])
		tid, _ := m["tid"].(string)
		results = append(results, Theme{Name: name, ID: tid})
	}

	if err := cursor.Err(); err != nil {
		log.Error(err)

		return nil, err
	}

	return results, nil
}

func ThemesGetAndDocs(uoid primitive.ObjectID, has_id bool) (any, error) {
	// db.theme.aggregate([
	// 	{
	// 	  $lookup: {
	// 		from: "group",
	// 		localField: "_id",
	// 		foreignField: "_toid",
	// 		as: "groups"
	// 	  }
	// 	},
	// 	{
	// 	  $unwind: "$groups"
	// 	},
	// 	{
	// 	  $lookup: {
	// 		from: "doc",
	// 		localField: "groups._id",
	// 		foreignField: "_goid",
	// 		as: "groups.docs"
	// 	  }
	// 	},
	// 	{
	// 	  $group: {
	// 		_id: "$_id",
	// 		theme_name: { $first: "$name" },
	// 		tid: { $first: "$tid" },
	// 		groups: { $push: "$groups" }
	// 	  }
	// 	},
	// 	{
	// 	  $project: {
	// 		_id: 0,
	// 		tid: 1,
	// 		theme_name: 1,
	// 		groups: {
	// 		  $map: {
	// 			input: "$groups",
	// 			as: "group",
	// 			in: {
	// 			  gid: "$$group.gid", // 假设 "gid" 是 "group" 中的一个字段
	// 			  name: "$$group.name",
	// 			  docs: {
	// 				$map: {
	// 				  input: "$$group.docs",
	// 				  as: "doc",
	// 				  in: {
	// 					did: "$$doc.did",
	// 					plain_text: "$$doc.plain_text",
	// 					title: "$$doc.title"
	// 				  }
	// 				}
	// 			  }
	// 			}
	// 		  }
	// 		}
	// 	  }
	// 	}
	// ])

	type doc struct {
		Did      string             `json:"did" bson:"did"`
		Content  m.DocContent       `json:"content" bson:"content"`
		CreateAt primitive.DateTime `json:"createAt" bson:"createAt"`
		UpdateAt primitive.DateTime `json:"updateAt" bson:"updateAt"`
		Level    int                `json:"level" bson:"level"`
	}
	type group struct {
		Gid  string `json:"gid" bson:"gid"`
		Name []byte `json:"name" bson:"name"`
		Docs []doc  `json:"docs" bson:"docs"`
	}
	type theme struct {
		Tid       string  `json:"tid" bson:"tid"`
		ThemeName []byte  `json:"theme_name" bson:"theme_name"`
		Groups    []group `json:"groups" bson:"groups"`
	}

	pipeline := mongo.Pipeline{
		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "group"},
			{Key: "localField", Value: "_id"},
			{Key: "foreignField", Value: "_toid"},
			{Key: "as", Value: "groups"},
		}}},
		{{Key: "$unwind", Value: "$groups"}},
		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "doc"},
			{Key: "localField", Value: "groups._id"},
			{Key: "foreignField", Value: "_goid"},
			{Key: "as", Value: "groups.docs"},
		}}},
		{{Key: "$group", Value: bson.D{
			{Key: "_id", Value: "$_id"},
			{Key: "theme_name", Value: bson.D{{Key: "$first", Value: "$name"}}},
			{Key: "tid", Value: bson.D{{Key: "$first", Value: "$tid"}}},
			{Key: "groups", Value: bson.D{{Key: "$push", Value: "$groups"}}},
		}}},
		{{Key: "$project", Value: bson.D{
			{Key: "_id", Value: 0},
			{Key: "tid", Value: 1},
			{Key: "theme_name", Value: 1},
			{Key: "groups", Value: bson.D{
				{Key: "$map", Value: bson.D{
					{Key: "input", Value: "$groups"},
					{Key: "as", Value: "group"},
					{Key: "in", Value: bson.D{
						{Key: "gid", Value: "$$group.gid"},
						{Key: "name", Value: "$$group.name"},
						{Key: "docs", Value: bson.D{
							{Key: "$map", Value: bson.D{
								{Key: "input", Value: "$$group.docs"},
								{Key: "as", Value: "doc"},
								{Key: "in", Value: bson.D{
									{Key: "did", Value: "$$doc.did"},
									{Key: "content", Value: "$$doc.content"},
									{Key: "createAt", Value: "$$doc.createAt"},
									{Key: "updateAt", Value: "$$doc.updateAt"},
									{Key: "level", Value: "$$doc.level"},
								}},
							}},
						}},
					}},
				}},
			}},
		}}},
	}

	cursor, err := db.Collection("theme").Aggregate(context.TODO(), pipeline)
	if err != nil {
		log.Error(err)
		return nil, err
	}
	defer cursor.Close(context.TODO())

	var results []theme
	if err = cursor.All(context.TODO(), &results); err != nil {
		log.Error(err)
		return nil, err
	}

	return results, nil
}
func ThemesGetAndDocsDetail(uoid primitive.ObjectID, has_id bool) (any, error) {
	// db.theme.aggregate([
	// 	{
	// 	  $lookup: {
	// 		from: "group",
	// 		localField: "_id",
	// 		foreignField: "_toid",
	// 		as: "groups"
	// 	  }
	// 	},
	// 	{
	// 	  $unwind: "$groups"
	// 	},
	// 	{
	// 	  $lookup: {
	// 		from: "doc",
	// 		localField: "groups._id",
	// 		foreignField: "_goid",
	// 		as: "groups.docs"
	// 	  }
	// 	},
	// 	{
	// 	  $lookup: {
	// 		from: "group",
	// 		localField: "_id",
	// 		foreignField: "_toid",
	// 		as: "groups"
	// 	  }
	// 	},
	// 	{
	// 	  $group: {
	// 		_id: "$_id",
	// 		theme_name: { $first: "$name" },
	// 		tid: { $first: "$tid" },
	// 		groups: { $push: "$groups" }
	// 	  }
	// 	},
	// 	{
	// 	  $project: {
	// 		_id: 0,
	// 		tid: 1,
	// 		theme_name: 1,
	// 		groups: {
	// 		  $map: {
	// 			input: "$groups",
	// 			as: "group",
	// 			in: {
	// 			  gid: "$$group.gid", // 假设 "gid" 是 "group" 中的一个字段
	// 			  name: "$$group.name",
	// 			  docs: {
	// 				$map: {
	// 				  input: "$$group.docs",
	// 				  as: "doc",
	// 				  in: {
	// 					did: "$$doc.did",
	// 					plain_text: "$$doc.plain_text",
	// 					title: "$$doc.title",
	// 				    content: "$$doc.content",
	// 				    level: "$$doc.level",
	// 				    createAt: "$$doc.createAt",
	// 				    updateAt: "$$doc.updateAt"
	// 				  }
	// 				}
	// 			  }
	// 			}
	// 		  }

	// 		}
	// 	}
	// }
	// ])

	type doc struct {
		Did      string             `json:"did" bson:"did"`
		Content  m.DocContent       `json:"content" bson:"content"`
		Level    int                `json:"level" bson:"level"`
		CreateAt primitive.DateTime `json:"createAt" bson:"createAt"`
		UpdateAt primitive.DateTime `json:"updateAt" bson:"updateAt"`
	}
	type group struct {
		Gid  string `json:"gid" bson:"gid"`
		Name []byte `json:"name" bson:"name"`
		Docs []doc  `json:"docs" bson:"docs"`
	}
	type theme struct {
		Tid       string  `json:"tid" bson:"tid"`
		ThemeName []byte  `json:"theme_name" bson:"theme_name"`
		Groups    []group `json:"groups" bson:"groups"`
	}

	pipeline := mongo.Pipeline{
		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "group"},
			{Key: "localField", Value: "_id"},
			{Key: "foreignField", Value: "_toid"},
			{Key: "as", Value: "groups"},
		}}},
		{{Key: "$unwind", Value: "$groups"}},
		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "doc"},
			{Key: "localField", Value: "groups._id"},
			{Key: "foreignField", Value: "_goid"},
			{Key: "as", Value: "groups.docs"},
		}}},
		{{Key: "$group", Value: bson.D{
			{Key: "_id", Value: "$_id"},
			{Key: "theme_name", Value: bson.D{{Key: "$first", Value: "$name"}}},
			{Key: "tid", Value: bson.D{{Key: "$first", Value: "$tid"}}},
			{Key: "groups", Value: bson.D{{Key: "$push", Value: "$groups"}}},
		}}},
		{{Key: "$project", Value: bson.D{
			{Key: "_id", Value: 0},
			{Key: "tid", Value: 1},
			{Key: "theme_name", Value: 1},
			{Key: "groups", Value: bson.D{
				{Key: "$map", Value: bson.D{
					{Key: "input", Value: "$groups"},
					{Key: "as", Value: "group"},
					{Key: "in", Value: bson.D{
						{Key: "gid", Value: "$$group.gid"},
						{Key: "name", Value: "$$group.name"},
						{Key: "docs", Value: bson.D{
							{Key: "$map", Value: bson.D{
								{Key: "input", Value: "$$group.docs"},
								{Key: "as", Value: "doc"},
								{Key: "in", Value: bson.D{
									{Key: "did", Value: "$$doc.did"},
									{Key: "content", Value: "$$doc.content"},
									{Key: "level", Value: "$$doc.level"},
									{Key: "createAt", Value: "$$doc.createAt"},
									{Key: "updateAt", Value: "$$doc.updateAt"},
								}},
							}},
						}},
					}},
				}},
			}},
		}}},
	}

	cursor, err := db.Collection("theme").Aggregate(context.TODO(), pipeline)
	if err != nil {
		log.Error(err)
		return nil, err
	}
	defer cursor.Close(context.TODO())

	var results []theme
	if err = cursor.All(context.TODO(), &results); err != nil {
		log.Error(err)
		return nil, err
	}

	return results, nil

}
func ThemeCreate(uoid primitive.ObjectID, req *RequestThemePost) (primitive.ObjectID, string, error) {

	tid := sys.CreateUUID()
	theme := bson.D{
		{Key: "_uid", Value: uoid},
		{Key: "name", Value: req.Data.Name},
		{Key: "createAt", Value: sys.StringtoTime(req.Data.CreateAt)},
		{Key: "tid", Value: tid},
	}
	ret, err := db.Collection("theme").InsertOne(context.TODO(), theme)

	return ret.InsertedID.(primitive.ObjectID), tid, err
}
func ThemeUpdate(toid primitive.ObjectID, req *RequestThemePut) error {

	filter := bson.M{
		"_id": toid,
	}
	update := bson.M{
		"$set": bson.M{
			"name": req.Data.Name,
		},
	}

	_, err := db.Collection("theme").UpdateOne(
		context.TODO(),
		filter,
		update,
		nil,
	)
	return err
}
func ThemeDelete(toid primitive.ObjectID) error {

	// 根据toid返回所有goids
	goids, err := GetGOIDsFromTOID(toid)
	if err != nil {
		return err
	}

	for _, goid := range goids {

		if err := DocDeleteFromGOID(goid); err != nil {
			return err
		}

		if err := GroupDeleteFromGOID(goid); err != nil {
			return err
		}
	}

	filter := bson.M{
		"_id": toid,
	}
	_, err = db.Collection("theme").DeleteOne(context.TODO(),
		filter,
		nil,
	)
	return err
}
