package modb

import (
	"context"
	"sys"

	log "github.com/tengfei-xy/go-log"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type Theme struct {
	Name string `json:"name" bson:"name"`
	ID   string `json:"id" bson:"tid"`
}

type RequestThemePut struct {
	Data struct {
		Name   string `json:"name"`
		UPTime string `json:"uptime"`
	} `json:"data" `
}

type RequestThemePostDefaultGroup struct {
	Name     string `json:"name"`
	CRTime   string `json:"crtime"`
	OverTime string `json:"overtime"`
}

type RequestThemePost struct {
	Data struct {
		Name         string                       `json:"name"`
		CRTime       string                       `json:"crtime"`
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
		return nil, err
	}

	for cursor.Next(context.TODO()) {
		var result Theme
		err := cursor.Decode(&result)
		if err != nil {
			return nil, err
		}
		results = append(results, result)
	}

	if err := cursor.Err(); err != nil {
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
	//   ])

	type doc struct {
		Did       string `json:"did" bson:"did"`
		PlainText string `json:"plain_text" bson:"plain_text"`
		Title     string `json:"title" bson:"title"`
	}
	type group struct {
		Gid  string `json:"gid" bson:"gid"`
		Name string `json:"name" bson:"name"`
		Docs []doc  `json:"docs" bson:"docs"`
	}
	type theme struct {
		Tid       string  `json:"tid" bson:"tid"`
		ThemeName string  `json:"theme_name" bson:"theme_name"`
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
									{Key: "plain_text", Value: "$$doc.plain_text"},
									{Key: "title", Value: "$$doc.title"},
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
	// 				    crtime: "$$doc.crtime",
	// 				    uptime: "$$doc.uptime"
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
		Did       string             `json:"did" bson:"did"`
		PlainText string             `json:"plain_text" bson:"plain_text"`
		Content   string             `json:"content" bson:"content"`
		Level     int                `json:"level" bson:"level"`
		CRTime    primitive.DateTime `json:"crtime" bson:"crtime"`
		UPTime    primitive.DateTime `json:"uptime" bson:"uptime"`
		Title     string             `json:"title" bson:"title"`
	}
	type group struct {
		Gid  string `json:"gid" bson:"gid"`
		Name string `json:"name" bson:"name"`
		Docs []doc  `json:"docs" bson:"docs"`
	}
	type theme struct {
		Tid       string  `json:"tid" bson:"tid"`
		ThemeName string  `json:"theme_name" bson:"theme_name"`
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
									{Key: "plain_text", Value: "$$doc.plain_text"},
									{Key: "title", Value: "$$doc.title"},
									{Key: "content", Value: "$$doc.content"},
									{Key: "level", Value: "$$doc.level"},
									{Key: "crtime", Value: "$$doc.crtime"},
									{Key: "uptime", Value: "$$doc.uptime"},
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
		{Key: "crtime", Value: sys.StringtoTime(req.Data.CRTime)},
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
