package util

import (
	"fmt"

	"github.com/golang-jwt/jwt/v5"
)

const (
	JwtEnvSecretKey = "HOME_JWT_SECRET"
)

type JWTClaims struct {
	AccountID string   `json:"aid"`
	UserID    string   `json:"uid"`
	Username  string   `json:"username"`
	Email     string   `json:"email"`
	Category  CAtegory `json:"category"`
	jwt.RegisteredClaims
}

func (j *JWTClaims) GetCategoryPrefix() CAtegory {
	return CAtegory(j.Category.GetAuthCookiePrefix())
}
func (j *JWTClaims) GetKeyName() string {
	return fmt.Sprintf("%s:account:%s:%s", j.GetCategoryPrefix(), j.AccountID, j.UserID)
}
