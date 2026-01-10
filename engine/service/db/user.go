package db

import (
	"errors"
	"net/http"
	"unicode/utf8"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	log "github.com/tengfei-xy/go-log"
	"gorm.io/gorm"
)

// UserModel matches ddl.sql(users).
type UserModel struct {
	ID uuid.UUID `gorm:"type:uuid;primaryKey"`
}

func (UserModel) TableName() string { return "users" }

func ExistUser() gin.HandlerFunc {
	return func(g *gin.Context) {
		uid, _, ok := g.Request.BasicAuth()
		if !ok || uid == "" {
			g.AbortWithStatusJSON(http.StatusBadRequest, "缺少uid")
			return
		}
		if !utf8.ValidString(uid) {
			g.AbortWithStatusJSON(http.StatusBadRequest, "uid编码非法")
			return
		}
		g.Set("uid", uid)

		if _, err := EnsureUser(uid); err != nil {
			log.Error(err)
			g.AbortWithStatus(http.StatusInternalServerError)
			return
		}
	}
}

// EnsureUser finds uid and returns its UUID (users.id), creating a row if missing.
func EnsureUser(uid string) (string, error) {
	if uid == "" || !utf8.ValidString(uid) {
		return "", errors.New("uid contains invalid utf-8")
	}
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return "", err
	}

	var user UserModel
	result := DB.Where("id = ?", uidUUID).First(&user)

	if result.Error == nil {
		return user.ID.String(), nil
	}

	if !errors.Is(result.Error, gorm.ErrRecordNotFound) {
		return "", result.Error
	}

	newUser := UserModel{ID: uidUUID}
	if err := DB.Create(&newUser).Error; err != nil {
		return "", err
	}

	log.Infof("新用户 uid=%s", uid)
	return newUser.ID.String(), nil
}

// UserDelete deletes a user by their UUID string.
func UserDelete(uid string) error {
	if uid == "" {
		return errors.New("uid is empty")
	}
	uidUUID, err := uuid.Parse(uid)
	if err != nil {
		return err
	}
	return DB.Where("id = ?", uidUUID).Delete(&UserModel{}).Error
}
