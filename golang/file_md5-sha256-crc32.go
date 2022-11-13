package main

import (
	"crypto/md5"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"hash/crc32"
	"io"
	"log"
	"os"
)

func md5File(fileName string) string {
	f, err := os.Open(fileName)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	h := md5.New()
	if _, err := io.Copy(h, f); err != nil {
		log.Fatal(err)
	}

	return hex.EncodeToString(h.Sum(nil))
}

func md5String(text string) string {
	hash := md5.Sum([]byte(text))
	return hex.EncodeToString(hash[:])
}

func sha256File(fileName string) string {
	f, err := os.Open(fileName)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		log.Fatal(err)
	}

	return hex.EncodeToString(h.Sum(nil))
}

func crc32File(fileName string) string {
	var returnCRC32String string
	file, err := os.Open(fileName)
	if err != nil {
		return returnCRC32String
	}
	defer file.Close()
	var polynomial uint32 = 0xedb88320
	tablePolynomial := crc32.MakeTable(polynomial)
	hash := crc32.New(tablePolynomial)
	if _, err := io.Copy(hash, file); err != nil {
		return returnCRC32String
	}
	hashInBytes := hash.Sum(nil)[:]
	returnCRC32String = hex.EncodeToString(hashInBytes)
	return returnCRC32String
}

func main() {

	//fmt.Printf(md5File("E:\\proj\\gotest2\\go.mod"))
	//fmt.Printf(md5String("ideaIU-2022.2.exe"))
	fmt.Printf(sha256File("E:\\proj\\gotest2\\go.mod"))
	//fmt.Printf(crc32File("D:\\tmp\\ideaIU-2022.2.exe"))

}
