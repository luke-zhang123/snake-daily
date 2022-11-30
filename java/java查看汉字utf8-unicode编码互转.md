
```
import java.nio.charset.StandardCharsets;

public class Test01 {

    public static void main(String[] args) {
        System.out.println("start");

//      汉字 utf8 unicode编码查看
        String hanZi = "万";

        System.out.println("汉字: " + hanZi);
        byte[] ziUtf8 = hanZi.getBytes(StandardCharsets.UTF_8);
        System.out.printf("%02x %02x %02x ,utf-8编码值%n",ziUtf8[0],ziUtf8[1],ziUtf8[2]);
        System.out.printf("%s %s %s ,utf-8二进制%n",
                String.format("%8s", Integer.toBinaryString(ziUtf8[0] & 0xFF)).replace(' ', '0'),
                String.format("%8s", Integer.toBinaryString(ziUtf8[1] & 0xFF)).replace(' ', '0'),
                String.format("%8s", Integer.toBinaryString(ziUtf8[2] & 0xFF)).replace(' ', '0'));

        String utf81 = String.format("%8s", Integer.toBinaryString(ziUtf8[0] & 0xFF)).replace(' ', '0');
        String utf82 = String.format("%8s", Integer.toBinaryString(ziUtf8[1] & 0xFF)).replace(' ', '0');
        String utf83 = String.format("%8s", Integer.toBinaryString(ziUtf8[2] & 0xFF)).replace(' ', '0');
        System.out.printf("[%s] [%s] [%s] ,utf-8编码拆解%n",
                utf81.substring(0,4) +" "+ utf81.substring(4),
                utf82.substring(0,2) +" "+ utf82.substring(2),
                utf83.substring(0,2) +" "+ utf83.substring(2));

        char ziUnicode = hanZi.charAt(0);
        System.out.println("\\u" + Integer.toHexString(ziUnicode & 0xffff) +" ,unicode编码");
        String ziUnicodeCode = String.format("%16s", Integer.toBinaryString(ziUnicode & 0xffff)).replace(' ', '0');
        System.out.println(ziUnicodeCode.substring(0,8) +" "+ ziUnicodeCode.substring(8) +" ,unicode二进制");
        System.out.println(ziUnicodeCode.substring(0,4) +" "+ ziUnicodeCode.substring(4,10) +" "+ ziUnicodeCode.substring(10) +" ,unicode编码拆解");

//      utf8 unicode 值转汉字
        byte[] codeUtf8 = {(byte) 0xe4, (byte) 0xb8, (byte) 0x87};
        System.out.println(new String(codeUtf8, StandardCharsets.UTF_8));
        
        int codeUnicode = Integer.parseInt("4e07",16);
        System.out.println((char)codeUnicode);
    }
}

```