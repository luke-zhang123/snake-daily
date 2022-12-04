
byte a= -16 对应的二进制是 256-16, 240的二进制表示, 是 a & 0xff

```
public static byte[] hexStringToByteArray(String s) {
    int len = s.length();
    byte[] data = new byte[len / 2];
    for (int i = 0; i < len; i += 2) {
        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                + Character.digit(s.charAt(i+1), 16));
    }
    return data;
}

// 𫠜 
String zi = "\uD86E\uDC1C";
System.out.println(zi);
byte[] ziArr = hexStringToByteArray("f0aba09c");
System.out.println(new String(ziArr));
```
查看字的各个编码
```
String zi = "\uD854\uDD7D";
System.out.println(zi); // 𥅽
System.out.println(Bin.bArr2HStr(zi.getBytes(), true)); // f0a5 85bd
System.out.println(Bin.bArr2HStr(zi.getBytes("utf-8"), true)); // f0a5 85bd
System.out.println(Bin.bArr2HStr(zi.getBytes("gb18030"), true)); // 9638 c837
System.out.println(Bin.bArr2HStr(zi.getBytes("utf-16"), true)); // feff d854 dd7d // feff 是utf bom头，小端
System.out.println(Bin.bArr2HStr(zi.getBytes("utf-32"), true)); // 0002 517d

byte[] codeUtf8_1 = {(byte) 0xd8, (byte) 0x54, (byte) 0xdd, (byte) 0x7d};
System.out.println(new String(codeUtf8_1, StandardCharsets.UTF_16));
byte[] codeUtf8_2 = {(byte) 0xfe, (byte) 0xff, (byte) 0xd8, (byte) 0x54, (byte) 0xdd, (byte) 0x7d};
System.out.println(new String(codeUtf8_2, StandardCharsets.UTF_16));
```

打印ascii
```
// 9 -> tab, 10 -> LF 换行, 13 -> CR 回车
public static void printASCII() {
    for (int i = 0; i < 255; i++) {
        System.out.printf("%3d [%3x] [%3s] | ",i,i,(char)i);
        if (i != 0 && (i+1) % 5 == 0) System.out.println();
    }
}
```