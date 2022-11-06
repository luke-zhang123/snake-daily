rc4，别名ARC4或ARCFOUR，流加密，异或两次还原，加密后串长度与原数据长度相同，因为是循环原数据长度做异或

openssl的rc4 key要128位，16字节，而且指定password会使用 kdf (key derivation functions) 算法 (OpenSSL's EVP_BytesToKey())，提取出128位的key，所以直接用指定password做rc4运算结果不同

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
echo -ne 'Message to be encrypted!!!' |openssl rc4 -K 54FD6FC0CFBB34BD6E5A6742D965B658 -nosalt -e -nopad |od -A n -t x1 |tr '\n' ' ' |sed 's/ //g'

# 16进制还原二进制解密
echo -ne '3604632e2f503ecb90c108acd3b03e0f22bde362754f02b1d466' |xxd -r -p |openssl rc4 -d -k 'p@ssw0rD' -nosalt -d -nopad


```

