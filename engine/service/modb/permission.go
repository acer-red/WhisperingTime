package modb

import (
	"context"
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

const (
	ResourceTypeTheme = "theme"
	ResourceTypeGroup = "group"
	ResourceTypeDoc   = "doc"

	RoleOwner  = "owner"
	RoleEditor = "editor"
	RoleViewer = "viewer"
)

// Permission stores the envelope-encrypted data key binding between a user and a resource.
// EncryptedKey must already be encrypted on the client side; the backend only persists it.
type Permission struct {
	UOID         primitive.ObjectID `bson:"_uid" json:"_uid"`
	ResourceID   string             `bson:"resource_id" json:"resource_id"`
	ResourceType string             `bson:"resource_type" json:"resource_type"`
	Role         string             `bson:"role" json:"role"`
	EncryptedKey []byte             `bson:"encrypted_key" json:"encrypted_key"`
	CreatedAt    time.Time          `bson:"created_at" json:"created_at"`
	UpdatedAt    time.Time          `bson:"updated_at" json:"updated_at"`
}

// PermissionUpsert stores or updates a permission record for the given user and resource.
func PermissionUpsert(uoid primitive.ObjectID, resourceID, resourceType, role string, encryptedKey []byte) error {
	if uoid == primitive.NilObjectID {
		return errors.New("missing user object id")
	}
	if resourceID == "" {
		return errors.New("missing resource id")
	}
	if resourceType == "" {
		return errors.New("missing resource type")
	}
	if len(encryptedKey) == 0 {
		return errors.New("missing encrypted key")
	}

	now := time.Now()
	_, err := db.Collection("permission").UpdateOne(
		context.TODO(),
		bson.M{"_uid": uoid, "resource_id": resourceID, "resource_type": resourceType},
		bson.M{
			"$set": bson.M{
				"role":          role,
				"encrypted_key": encryptedKey,
				"updated_at":    now,
			},
			"$setOnInsert": bson.M{
				"created_at": now,
			},
		},
		options.Update().SetUpsert(true),
	)
	return err
}

// PermissionsFor returns permissions for a user and resource ids keyed by resource_id.
func PermissionsFor(uoid primitive.ObjectID, resourceType string, resourceIDs []string) (map[string]Permission, error) {
	result := make(map[string]Permission)
	if uoid == primitive.NilObjectID || len(resourceIDs) == 0 {
		return result, nil
	}

	filter := bson.M{
		"_uid":          uoid,
		"resource_type": resourceType,
		"resource_id":   bson.M{"$in": resourceIDs},
	}

	cursor, err := db.Collection("permission").Find(context.TODO(), filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(context.TODO())

	for cursor.Next(context.TODO()) {
		var p Permission
		if err := cursor.Decode(&p); err != nil {
			return nil, err
		}
		result[p.ResourceID] = p
	}
	return result, cursor.Err()
}

// PermissionGet returns a single permission for the given user and resource id.
func PermissionGet(uoid primitive.ObjectID, resourceType, resourceID string) (*Permission, error) {
	if uoid == primitive.NilObjectID || resourceID == "" || resourceType == "" {
		return nil, errors.New("invalid permission query")
	}
	filter := bson.M{"_uid": uoid, "resource_id": resourceID, "resource_type": resourceType}
	var p Permission
	if err := db.Collection("permission").FindOne(context.TODO(), filter).Decode(&p); err != nil {
		return nil, err
	}
	return &p, nil
}

// PermissionDelete removes all permission records for the given resource ids and type.
func PermissionDelete(resourceType string, resourceIDs []string) error {
	if resourceType == "" || len(resourceIDs) == 0 {
		return nil
	}
	filter := bson.M{
		"resource_type": resourceType,
		"resource_id":   bson.M{"$in": resourceIDs},
	}
	_, err := db.Collection("permission").DeleteMany(context.TODO(), filter)
	return err
}
