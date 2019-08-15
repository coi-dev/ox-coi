package com.openxchange.oxcoi;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

class ShareHelper {
    private String fileName;

    /* Get uri related content real local file path. */
    String getUriRealPath(Context context, Uri uri)
    {
        String ret;

        ret = getUriPath(context, uri);

        return ret;
    }

    String getFileName(){
        return fileName;
    }

    private String getUriPath(Context context, Uri uri)
    {
        fileName = "";
        ContentResolver contentResolver = context.getContentResolver();

        //Get filename
        String[] projection = {MediaStore.MediaColumns.DISPLAY_NAME};
        Cursor metaCursor = contentResolver.query(uri, projection, null, null, null);
        if (metaCursor != null) {
            try {
                if (metaCursor.moveToFirst()) {
                    fileName = metaCursor.getString(0);
                }
            } finally {
                metaCursor.close();
            }
        }

        //Save file to cache directory
        File targetFile = new File(context.getCacheDir(), fileName);
        InputStream inputStream;

        try {
            inputStream = contentResolver.openInputStream(uri);
            try (OutputStream out = new FileOutputStream(targetFile)) {
                // Transfer bytes from in to out
                byte[] buf = new byte[1024];
                int len;
                if (inputStream != null) {
                    while ((len = inputStream.read(buf)) > 0) {
                        out.write(buf, 0, len);
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        return targetFile.getAbsolutePath();
    }
}
