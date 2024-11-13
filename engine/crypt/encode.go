package crypt

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/hex"
	"io"
)

// encrypt 加密函数
func Encode(stringToEncrypt string, keyString string) (encryptedString string) {

	// 将密钥转换为字节数组
	key := []byte(keyString)

	// 将明文转换为字节数组
	plaintext := []byte(stringToEncrypt)

	// 创建一个新的AES密码块
	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err.Error())
	}

	// 创建一个新的GCM密码块
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		panic(err.Error())
	}

	// 生成随机nonce
	nonce := make([]byte, aesGCM.NonceSize())
	if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
		panic(err.Error())
	}

	// 加密数据
	ciphertext := aesGCM.Seal(nonce, nonce, plaintext, nil)
	return hex.EncodeToString(ciphertext)
}
