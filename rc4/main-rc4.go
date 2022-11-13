package main

import (
	"crypto/rc4"
	"encoding/hex"
	"fmt"
)

func main() {

	fmt.Println("start")

	key, _ := hex.DecodeString("54FD6FC0CFBB34BD6E5A6742D965B658")
	c, _ := rc4.NewCipher([]byte(key))

	data1 := "01 Message to be encrypted!!!"
	dst1 := make([]byte, len(data1))
	c.XORKeyStream(dst1, []byte(data1))
	fmt.Println(hex.EncodeToString(dst1))

	data2 := "01 Message to be encrypted!!!"
	dst2 := make([]byte, len(data2))
	c.XORKeyStream(dst2, []byte(data2))
	fmt.Println(hex.EncodeToString(dst2))

	data3 := "01 Message to be encrypted!!!"
	dst3 := make([]byte, len(data3))
	c.XORKeyStream(dst3, []byte(data3))
	fmt.Println(hex.EncodeToString(dst3))
}
