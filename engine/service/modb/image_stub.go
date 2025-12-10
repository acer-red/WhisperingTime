package modb

import (
	"errors"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Deprecated image helpers retained for compatibility with legacy RPCs.
func ImageCreate(name string, data []byte, uoid primitive.ObjectID) error {
	return errors.New("deprecated: use presigned file upload instead")
}

func ImageDelete(name string) error {
	return errors.New("deprecated: use presigned file upload instead")
}
