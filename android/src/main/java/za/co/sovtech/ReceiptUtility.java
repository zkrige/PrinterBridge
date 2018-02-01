package za.co.sovtech;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.Html;
import android.util.Log;

import java.io.ByteArrayOutputStream;

public class ReceiptUtility {

    private static byte[] INIT = {0x1B,0x40};
    private static byte[] POWER_ON = {0x1B,0x3D,0x01};
    private static byte[] POWER_OFF = {0x1B,0x3D,0x02};
    private static byte[] NEW_LINE = {0x0A};
    private static byte[] ALIGN_LEFT = {0x1B,0x61,0x00};
    private static byte[] ALIGN_CENTER = {0x1B,0x61,0x01};
    private static byte[] ALIGN_RIGHT = {0x1B,0x61,0x02};
    private static byte[] EMPHASIZE_ON = {0x1B,0x45,0x01};
    private static byte[] EMPHASIZE_OFF = {0x1B,0x45,0x00};
    private static byte[] FONT_5X8 = {0x1B,0x4D,0x00};
    private static byte[] FONT_5X12 = {0x1B,0x4D,0x01};
    private static byte[] FONT_8X12 = {0x1B,0x4D,0x02};
    private static byte[] FONT_10X18 = {0x1B,0x4D,0x03};
    private static byte[] FONT_SIZE_0 = {0x1D,0x21,0x00};
    private static byte[] FONT_SIZE_1 = {0x1D,0x21,0x11};
    private static byte[] CHAR_SPACING_0 = {0x1B,0x20,0x00};
    private static byte[] CHAR_SPACING_1 = {0x1B,0x20,0x01};

    private static byte[] hexToByteArray(String s) {
        if(s == null) {
            s = "";
        }
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        for(int i = 0; i < s.length() - 1; i += 2) {
            String data = s.substring(i, i + 2);
            bout.write(Integer.parseInt(data, 16));
        }
        return bout.toByteArray();
    }

    private static byte[] convertBitmap(Bitmap bitmap, int targetWidth, int threshold) {
        int targetHeight = (int)Math.round((double)targetWidth / (double)bitmap.getWidth() * (double)bitmap.getHeight());

        byte[] pixels = new byte[targetWidth * targetHeight];
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, false);
        for(int j = 0; j < scaledBitmap.getHeight(); ++j) {
            for(int i = 0; i < scaledBitmap.getWidth(); ++i) {
                int pixel = scaledBitmap.getPixel(i, j);
                int alpha = (pixel >> 24) & 0xFF;
                int r = (pixel >> 16) & 0xFF;
                int g = (pixel >> 8) & 0xFF;
                int b = pixel & 0xFF;
                if(alpha < 50) {
                    pixels[i + j * scaledBitmap.getWidth()] = 0;
                } else if((r + g + b) / 3 >= threshold) {
                    pixels[i + j * scaledBitmap.getWidth()] = 0;
                } else {
                    pixels[i + j * scaledBitmap.getWidth()] = 1;
                }
            }
        }

        byte[] output = new byte[scaledBitmap.getWidth() * (int)Math.ceil((double)scaledBitmap.getHeight() / (double)8)];

        for(int i = 0; i < scaledBitmap.getWidth(); ++i) {
            for(int j = 0; j < (int)Math.ceil((double)scaledBitmap.getHeight() / (double)8); ++j) {
                for(int n = 0; n < 8; ++n) {
                    if(j * 8 + n < scaledBitmap.getHeight()) {
                        output[i + j * scaledBitmap.getWidth()] |= pixels[i + (j * 8 + n) * scaledBitmap.getWidth()] << (7 - n);
                    }
                }
            }
        }

        return output;
    }

    private static byte[] convertBarcode(Bitmap bitmap, int targetWidth, int threshold) {
        int targetHeight = (int)Math.round((double)targetWidth / (double)bitmap.getWidth() * (double)bitmap.getHeight());

        byte[] pixels = new byte[targetWidth];
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, false);
        for(int i = 0; i < scaledBitmap.getWidth(); ++i) {
            int pixel = scaledBitmap.getPixel(i, scaledBitmap.getHeight() / 2);
            int alpha = (pixel >> 24) & 0xFF;
            int r = (pixel >> 16) & 0xFF;
            int g = (pixel >> 8) & 0xFF;
            int b = pixel & 0xFF;
            if(alpha < 50) {
                pixels[i] = 0;
            } else if((r + g + b) / 3 >= threshold) {
                pixels[i] = 0;
            } else {
                pixels[i] = 1;
            }
        }

        byte[] output = new byte[(int)Math.ceil((double)scaledBitmap.getWidth() / 8.0)];

        for(int i = 0; i < scaledBitmap.getWidth(); ++i) {
            output[i / 8] |= pixels[i] << (7 - (i % 8));
        }

        return output;
    }

    private static int countOccurences(String source, String findString){
        int lastIndex = 0;
        int count = 0;

        while(lastIndex != -1){

            lastIndex = source.indexOf(findString,lastIndex);

            if(lastIndex != -1){
                count ++;
                lastIndex += findString.length();
            }
        }
        return count;
    }

    public static byte[] genReceipt(Context context, String reciept, boolean isMerchantReceipt, String tradingName) {

        String lineSep = System.getProperty("line.separator");
        String yourString= reciept;

        Log.d(ReceiptUtility.class.getName(), "<br/> count: "+countOccurences(reciept, "<br/>"));
        Log.d(ReceiptUtility.class.getName(), "<br> count: "+countOccurences(reciept, "<br>"));

        yourString= yourString.replaceAll("<br>", "brnl");
        yourString= yourString.replaceAll("<br/>", "brnl");

        Log.d(ReceiptUtility.class.getName(), yourString);

        yourString = Html.fromHtml(yourString).toString();

        yourString= yourString.replaceAll("brnl", lineSep);

        Log.d(ReceiptUtility.class.getName(), yourString);

        int lineWidth = 384;
        int size0NoEmphasizeLineWidth = 384 / 8; //line width / font width
        String singleLine = "";
        for(int i = 0; i < size0NoEmphasizeLineWidth; ++i) {
            singleLine += "-";
        }
        String doubleLine = "";
        for(int i = 0; i < size0NoEmphasizeLineWidth; ++i) {
            doubleLine += "=";
        }

        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            baos.write(INIT);
            baos.write(POWER_ON);
            baos.write(NEW_LINE);
            baos.write(ALIGN_CENTER);

            baos.write(FONT_SIZE_1);
            baos.write(FONT_10X18);
            baos.write(EMPHASIZE_ON);
            baos.write(tradingName.getBytes());
            baos.write(EMPHASIZE_OFF);

            baos.write(NEW_LINE);
            baos.write(CHAR_SPACING_0);

            baos.write(FONT_SIZE_1);
            baos.write(FONT_5X12);
            if(isMerchantReceipt){
                baos.write("Merchant Receipt".getBytes());
            }
            else{
                baos.write("Customer Receipt".getBytes());
            }

            baos.write(NEW_LINE);

            baos.write(FONT_SIZE_0);
            baos.write(FONT_8X12);
            baos.write(singleLine.getBytes());
            baos.write(NEW_LINE);

            baos.write(FONT_10X18);
            baos.write(ALIGN_LEFT);

            String[] lines = yourString.split(lineSep);

            for (String string : lines) {
                Log.d(ReceiptUtility.class.getName(), string);
                baos.write(EMPHASIZE_OFF);
                baos.write(string.trim().getBytes());
                baos.write(EMPHASIZE_ON);
                baos.write(NEW_LINE);
            }


            baos.write(NEW_LINE);
            baos.write(NEW_LINE);
            baos.write(ALIGN_CENTER);

            baos.write("Powered by SureSwipe".getBytes());
            baos.write(NEW_LINE);
            baos.write(NEW_LINE);
            baos.write(NEW_LINE);
            baos.write(NEW_LINE);
            baos.write(NEW_LINE);
            baos.write(NEW_LINE);

            baos.write(POWER_OFF);

            return baos.toByteArray();
        } catch(Exception e) {
            e.printStackTrace();
        }

        return null;
    }

}
