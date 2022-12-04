

- ls -d */

查看当前目录下的目录

- nslookup lncn.org 1.0.0.1

yum whatprovides '*/nslookup'

yum install bind-utils

指定dns服务器，查询域名

- curl -v https://lncn.org --resolve 'lncn.org:443:104.21.95.3'

指定ip访问域名

- lscpu | grep Byte.Order

查看cpu大小端，x86小端，高位在大的地址端

16进制还原到二进制，不加写入文件，直接终端显示,下面是一个utf8 4字节汉字
echo f0a585bd | xxd -p -r > bin.dat

vi查看文件二进制 :%!xxd

查看16进制字符的01bit字符，16进制字符要大写
echo "obase=2; ibase=16; E" |bc

转大写
echo "abcd123ddd" |tr 'a-z' 'A-Z'

16进制字符转二进制补0
echo "obase=2; ibase=16; 6D" |bc |awk '{printf("%08d\n", $1)}'

二进制字符转16进制字符
echo "obase=16; ibase=2; 11100100" |bc

当前四个字节汉字的范围是 \U00020000 ~ \U0002B81D
𫠜 U+2B81C Decimal[178204]	UTF-8[F0 AB A0 9C]	UTF-16[D86E DC1C]	UTF-32[0002B81C] https://www.unicode.org/cgi-bin/GetUnihanData.pl?codepoint=2B81C&useutf8=true
𥅽,是一个utf8的4字节汉字
𥅽 U+2517D Decimal[151933]	UTF-8[F0 A5 85 BD]	UTF-16[D854 DD7D]	UTF-32[0002517D] http://www.unicode.org/cgi-bin/GetUnihanData.pl?codepoint=2517D
```
vi打开，显示 𥅽 的unicode <d854><dd7d> ,下面前三个字节按照utf8编码保存d854
echo eda194edb5bd |xxd -p -r >test.ttt

vi打开可以看到汉字  𥅽
echo f0a585bd |xxd -p -r >test_utf8.txt
iconv -f UTF-8 -t GB18030 test_utf8.txt > test_gb18030.txt
vi -c 'e ++enc=gb18030' test_gb18030.txt
iconv -f UTF-8 -t UTF-16 test_utf8.txt > test_utf16.txt
vim -c 'e ++enc=utf-16le' test_utf16.txt # fffe 54d8 7ddd

echo 9638c837 |xxd -p -r >test_gb18030.txt
vi -c 'e ++enc=gb18030' test_gb18030.txt

echo d854dd7d |xxd -p -r >test_utf16.txt
vim -c 'e ++enc=utf-16' test_utf16.txt

大小端测试
echo fffe54d87ddd |xxd -p -r >test_utf16le.txt
vim -c 'e ++enc=utf-16le' test_utf16le.txt
echo feffd854dd7d |xxd -p -r >test_utf16be.txt
vim -c 'e ++enc=utf-16be' test_utf16be.txt

d854 dd7d
11011000 01010100 11011101 01111101

eda194edb5bd
11101101 10100001 10010100 11101101 10110101 10111101

f0a585bd
11110000 10100101 10000101 10111101

String zi = "\uD854\uDD7D";
System.out.println(zi);
byte[] codeUtf8 = {(byte) 0xd8, (byte) 0x54, (byte) 0xdd, (byte) 0x7d};
System.out.println(new String(codeUtf8, StandardCharsets.UTF_16));
```

查看文件二进制，直接用hexdump显示是小端，1,2高低字节反了
hexdump -C test.txt
od -t x1 test.txt
hexdump -e '16/1 "%02x " "\n"' test.txt

|Character	|UTF-8	|UTF-16LE	|UTF-16BE|
|:--|:--|:--|:--|
|U+0041 (a)|	0x41|	0x41 0x00|	0x00 0x41|
U+00E5 (å)	|0xC3 0xA5|	0xE5 0x00|	0x00 0xE5|
U+201C (“)	|0xE2 0x80 0x9C|	0x1C 0x20|	0x20 0x1C|
U+1F4A9 (💩)	|0xF0 0x9F 0x92 0xA9|	0x3D 0xD8 0xA9 0xDC|	0xD8 0x3D 0xDC 0xA9|

