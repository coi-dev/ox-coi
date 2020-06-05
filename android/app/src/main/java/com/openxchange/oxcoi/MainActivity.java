/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

package com.openxchange.oxcoi;

import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;

public class MainActivity extends FlutterActivity {
    private Map<String, String> sharedData = new HashMap<>();
    private String startString = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        cacheDataFromPlatform(getIntent());
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        DartExecutor dartExecutor = flutterEngine.getDartExecutor();
        setupSharingMethodChannel(dartExecutor);
        setupSecurityMethodChannel(dartExecutor);
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        cacheDataFromPlatform(intent);
    }

    private void setupSharingMethodChannel(DartExecutor dartExecutor) {
        new io.flutter.plugin.common.MethodChannel(dartExecutor, MethodChannel.Sharing.NAME).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.contentEquals(MethodChannel.Sharing.Methods.GET_SHARE_DATA)) {
                        result.success(sharedData);
                        sharedData.clear();
                    } else if (call.method.contentEquals(MethodChannel.Sharing.Methods.GET_INITIAL_LINK)) {
                        if (startString != null && !startString.isEmpty()) {
                            result.success(startString);
                            startString = "";
                        } else {
                            result.success(null);
                        }
                    } else if (call.method.contentEquals(MethodChannel.Sharing.Methods.SEND_SHARE_DATA)) {
                        shareDataWithPlatform(call.arguments);
                        result.success(null);
                    }
                });
    }

    private void setupSecurityMethodChannel(DartExecutor dartExecutor) {
        SecurityHelper securityHelper = new SecurityHelper();
        new io.flutter.plugin.common.MethodChannel(dartExecutor, MethodChannel.Security.NAME).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.contentEquals(MethodChannel.Security.Methods.DECRYPT)) {
                        String encryptedBase64Content = call.argument(MethodChannel.Security.Arguments.CONTENT);
                        String privateKeyBase64 = call.argument(MethodChannel.Security.Arguments.PRIVATE_KEY);
                        String publicKeyBase64 = call.argument(MethodChannel.Security.Arguments.PUBLIC_KEY);
                        String authBase64 = call.argument(MethodChannel.Security.Arguments.AUTH);
                        byte[] inputBytes = Base64.decode(encryptedBase64Content, Base64.DEFAULT);
                        String decryptMessage = securityHelper.decryptMessage(inputBytes, privateKeyBase64, publicKeyBase64, authBase64);
                        result.success(decryptMessage);
                    }

                });
    }

    private void cacheDataFromPlatform(Intent intent) {
        String action = intent.getAction();
        String type = intent.getType();
        Uri data = intent.getData();

        if (Intent.ACTION_SEND.equals(action) && type != null) {
            if (type.startsWith("text/")) {
                String text = intent.getStringExtra(Intent.EXTRA_TEXT);
                sharedData.put(MethodChannel.Sharing.Arguments.MIME_TYPE, type);
                sharedData.put(MethodChannel.Sharing.Arguments.TEXT, text);
            } else if (type.startsWith("application/") || type.startsWith("audio/") || type.startsWith("image/") || type.startsWith("video/")) {
                Uri uri = (Uri) Objects.requireNonNull(getIntent().getExtras()).get(Intent.EXTRA_STREAM);
                if (uri == null) {
                    ClipData clipData = intent.getClipData();
                    if (clipData != null) {
                        ClipData.Item item = clipData.getItemAt(0);
                        uri = item.getUri();
                    }
                }
                if (uri != null) {
                    String text = intent.getStringExtra(Intent.EXTRA_TEXT);
                    ShareHelper shareHelper = new ShareHelper();
                    String uriPath = shareHelper.getFilePathForUri(this, uri);
                    if (text != null && !text.isEmpty()) {
                        sharedData.put(MethodChannel.Sharing.Arguments.TEXT, text);
                    }
                    sharedData.put(MethodChannel.Sharing.Arguments.MIME_TYPE, type);
                    sharedData.put(MethodChannel.Sharing.Arguments.PATH, uriPath);
                    sharedData.put(MethodChannel.Sharing.Arguments.NAME, shareHelper.getFileName());
                }
            }
        } else if (Intent.ACTION_VIEW.equals(action) && data != null) {
            startString = data.toString();
        }
    }

    private void shareDataWithPlatform(Object arguments) {
        @SuppressWarnings("unchecked")
        HashMap<String, String> argsMap = (HashMap<String, String>) arguments;
        String title = argsMap.get(MethodChannel.Sharing.Arguments.TITLE);
        String path = argsMap.get(MethodChannel.Sharing.Arguments.PATH);
        String mimeType = argsMap.get(MethodChannel.Sharing.Arguments.MIME_TYPE);
        String text = argsMap.get(MethodChannel.Sharing.Arguments.TEXT);

        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType(mimeType);
        if (path != null) {
            File fileToShare = new File(path);
            Uri contentUri = FileProvider.getUriForFile(this, this.getPackageName() + ".fileProvider", fileToShare);
            if (!path.isEmpty()) {
                shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
            }
        }
        // add optional text
        if (text != null && !text.isEmpty()) {
            shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        }
        this.startActivity(Intent.createChooser(shareIntent, title));
    }

}
