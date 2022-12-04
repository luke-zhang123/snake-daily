public class Bin {

    // byte2BinaryString
    public static String b2BStr(byte b) {
        return String.format("%8s",
                Integer.toBinaryString(b & 0xFF)).replace(' ', '0');
    }

    // hexString2ByteArray
    public static byte[] hStr2BArr(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i+1), 16));
        }
        return data;
    }
    // byteArray2BinaryString
    public static String bArr2BStr(byte[] bArr, boolean byteSeparate) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bArr) {
            String oneByteBinaryString = String.format("%8s",
                    Integer.toBinaryString(b & 0xFF)).replace(' ', '0');
            sb.append(oneByteBinaryString);
            if (byteSeparate) sb.append(" ");
        }
        return sb.toString();
    }
    // byteArray2HexString
    public static String bArr2HStr(byte[] bArr, boolean byteSeparate) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < bArr.length; i++) {
            String hex = String.format("%02x", bArr[i] & 0xFF);
            sb.append(hex);
            if (i != 0 && (i+1) % 2 == 0 ) sb.append(" ");
        }
        return sb.toString();
    }
}
