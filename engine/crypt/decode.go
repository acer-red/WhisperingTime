package crypt

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/hex"
)

func Decode(encryptedString string, keyString string) (decryptedString []byte) {

	// 将密钥转换为字节数组
	key := []byte(keyString)

	// 将加密字符串转换为字节数组
	enc, err := hex.DecodeString(encryptedString)
	if err != nil {
		panic(err.Error())
	}

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

	// 获取nonce
	nonceSize := aesGCM.NonceSize()
	nonce, ciphertext := enc[:nonceSize], enc[nonceSize:]

	// 解密数据
	plaintext, err := aesGCM.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		panic(err.Error())
	}

	return plaintext
}
