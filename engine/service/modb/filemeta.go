package modb

import (
	"context"
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

// FileMeta stores object storage metadata and envelope encryption info.
type FileMeta struct {
	OID               primitive.ObjectID `bson:"_id,omitempty"`
	ID                string             `bson:"id"`
	UID               string             `bson:"uid"`
	ThemeID           string             `bson:"theme_id"`
	GroupID           string             `bson:"group_id"`
	DocID             string             `bson:"doc_id"`
	ObjectPath        string             `bson:"object_path"`
	Mime              string             `bson:"mime"`
	Size              int64              `bson:"size"`
	EncryptedKey      []byte             `bson:"encrypted_key"`
	IV                []byte             `bson:"iv,omitempty"`
	EncryptedMetadata []byte             `bson:"encrypted_metadata,omitempty"`
	CreatedAt         time.Time          `bson:"created_at"`
	UpdatedAt         time.Time          `bson:"updated_at"`
}

// FileMetaCreate inserts a new file metadata record.
func FileMetaCreate(ctx context.Context, meta *FileMeta) error {
	if meta == nil {
		return errors.New("nil file meta")
	}
	if meta.ID == "" || meta.ObjectPath == "" || meta.UID == "" {
		return errors.New("missing required file meta fields")
	}
	meta.CreatedAt = time.Now()
	meta.UpdatedAt = meta.CreatedAt
	_, err := db.Collection("filemeta").InsertOne(ctx, meta)
	return err
}

// FileMetaDelete removes filemeta by id and returns the removed record for further cleanup.
func FileMetaDelete(ctx context.Context, fileID string) (*FileMeta, error) {
	if fileID == "" {
		return nil, errors.New("empty file id")
	}
	var fm FileMeta
	res := db.Collection("filemeta").FindOneAndDelete(ctx, bson.M{"id": fileID})
	if err := res.Decode(&fm); err != nil {
		return nil, err
	}
	return &fm, nil
}

// FileMetaListByDoc returns all filemeta entries bound to a doc.
func FileMetaListByDoc(ctx context.Context, docID string) ([]FileMeta, error) {
	if docID == "" {
		return nil, errors.New("empty doc id")
	}
	cursor, err := db.Collection("filemeta").Find(ctx, bson.M{"doc_id": docID})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var items []FileMeta
	for cursor.Next(ctx) {
		var fm FileMeta
		if err := cursor.Decode(&fm); err != nil {
			return nil, err
		}
		items = append(items, fm)
	}
	return items, cursor.Err()
}

// FileMetaGet returns metadata by file id.
func FileMetaGet(ctx context.Context, fileID string) (*FileMeta, error) {
	if fileID == "" {
		return nil, errors.New("empty file id")
	}
	var fm FileMeta
	err := db.Collection("filemeta").FindOne(ctx, bson.M{"id": fileID}).Decode(&fm)
	if errors.Is(err, mongo.ErrNoDocuments) {
		return nil, err
	}
	if err != nil {
		return nil, err
	}
	return &fm, nil
}
