rc4，别名ARC4或ARCFOUR，流加密(明文数据每次与密钥数据流顺次对应加密，得到密文数据流，相同ctx,连续每次EVP_CipherUpdate相同data，结果不一样,解密也要相同连续次序。一次加密全部和分批连续加密，最后密文一支，流式加密，密文与明文字节数一致)，异或两次还原，加密后串长度与原数据长度相同，因为是循环原数据长度做异或

openssl的rc4 key要128位，16字节，而且指定password会使用 kdf (key derivation functions) 算法 (OpenSSL's EVP_BytesToKey(), 使用md5摘要算法)，提取出128位的key，所以直接用指定password做rc4运算结果不同

以openssl的rc4加密结果为基准，成为其他语言实现的test case

```bash
# 指定password，打印openssl实际使用的key（16进制字符串），输出： key=54FD6FC0CFBB34BD6E5A6742D965B658
openssl rc4 -k 'p@ssw0rD'  -nosalt -e -nopad -p

# 使用指定password或key加密，xxd查看16进制，小写k指定password，大写K指定16进制key  install xxd, yum install vim-common
echo -ne 'Message to be encrypted!!!' |openssl rc4 -k 'p@ssw0rD' -nosalt -e -nopad |xxd
echo -ne 'Message to be encrypted!!!' |openssl rc4 -K 54FD6FC0CFBB34BD6E5A6742D965B658 -nosalt -e -nopad |xxd

# 加解密，-e加密 -d解密
echo -ne 'Message to be encrypted!!!' |openssl rc4 -k 'p@ssw0rD' -nosalt -e -nopad |openssl rc4 -k 'p@ssw0rD' -nosalt -d -nopad

# 密文16进制输出到一行，复制， x2是两个字节一组（默认是大端格式），x1就是一个字节一组
echo -ne 'Message to be encrypted!!!' |openssl rc4 -k 'p@ssw0rD' -nosalt -e -nopad |od -A n -t x1 |tr '\n' ' ' |sed 's/ //g'

# 16进制还原二进制解密
echo -ne '3604632e2f503ecb90c108acd3b03e0f22bde362754f02b1d466' |xxd -r -p |openssl rc4 -d -k 'p@ssw0rD' -nosalt -d -nopad

```

- 测试用例
```
# 单个基本测试
password='weakPassWd123'
key_kdf='3BEB19BAD494179FB48057F1EAA87F63' # hex
data='openssl-rc4 data test'
data_encrypt='8534449f5e81237e9adb34db9c91157b2c3832d032' # hex

# 单个基本测试
password='p@ssw0rD'
key_kdf='54FD6FC0CFBB34BD6E5A6742D965B658' # hex
data='Message to be rc4 encrypted!!!'
data_encrypt='3604632e2f503ecb90c108acd3b0290275efff7c62581fe081224defb9dc' # hex

# 连续消息加密，可以使用openssl把明文拼接一起加密，效果一样
password='p@ssw0rD'
key_kdf='54FD6FC0CFBB34BD6E5A6742D965B658' # hex

data='01 Message to be encrypted!!!'
data_encrypt='4b5030102b44288a83cb08bad9b0390461aaf471735316e4902308efb9' # hex

data='02 Message to be encrypted!!!'
data_encrypt='cdafcfb8eadf2aea6a2ea7d9d0e28da193cae5eea2e7a4697c25426cd8' # hex

data='03 Message to be encrypted!!!'
data_encrypt='f5f87f702850cc1e9a8bd8b67cb8827cbf66647f6cdbf65e8bdeaf8678' # hex

```