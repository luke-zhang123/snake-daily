
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
byte[] ziArr = hexStringToByteArray("f0aba09c");
System.out.println(new String(ziArr));
```