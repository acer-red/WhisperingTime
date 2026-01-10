package db

import (
	"context"
	"errors"

	"github.com/jackc/pgconn"
	log "github.com/tengfei-xy/go-log"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// Exported error for services to check
var ErrRecordNotFound = gorm.ErrRecordNotFound

func Init(dsn string) error {
	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Errorf("failed to connect database: %v", err)
		return err
	}

	// AutoMigrate
	err = DB.AutoMigrate(
		&UserModel{},
		&ThemeModel{},
		&GroupModel{},
		&DocModel{},
		&PermissionModel{},
		&FileMetaModel{},
		&ScaleTemplateModel{},
		&BGJobModel{},
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "42704" {
			// If a constraint is already absent, allow startup to proceed and warn.
			log.Warnf("migration warning: missing constraint %s (ignoring): %v", pgErr.ConstraintName, err)
		} else {
			log.Errorf("failed to migrate database: %v", err)
			return err
		}
	}

	return nil
}

// Transaction helper if needed
func WithTx(ctx context.Context, fn func(tx *gorm.DB) error) error {
	return DB.WithContext(ctx).Transaction(fn)
}

func GetDB() *gorm.DB {
	return DB
}

func Disconnect() error {
	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}
