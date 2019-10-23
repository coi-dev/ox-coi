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

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;

import androidx.core.content.FileProvider;

import java.io.File;
import java.security.KeyPair;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private Map<String, String> sharedData = new HashMap<>();
    private static final String SHARED_MIME_TYPE = "shared_mime_type";
    private static final String SHARED_TEXT = "shared_text";
    private static final String SHARED_PATH = "shared_path";
    private static final String SHARED_FILE_NAME = "shared_file_name";
    // TODO create constants for channel methods
    private static final String SHARING_CHANNEL_NAME = "oxcoi.sharing";
    // TODO create constants for channel methods
    private static final String SECURITY_CHANNEL_NAME = "oxcoi.security";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        SecurityHelper securityHelper = new SecurityHelper(this);
        handleSendIntent(getIntent());
        setupSharingMethodChannel();
        setupSecurityMethodChannel(securityHelper);
    }

    private void setupSharingMethodChannel() {
        new MethodChannel(getFlutterView(), SHARING_CHANNEL_NAME).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.contentEquals("getSharedData")) {
                        result.success(sharedData);
                        sharedData.clear();
                    }else if (call.method.contentEquals("sendSharedData")) {
                        shareFile(call.arguments);
                    }
                });
    }

    private void setupSecurityMethodChannel(SecurityHelper securityHelper) {
        new MethodChannel(getFlutterView(), SECURITY_CHANNEL_NAME).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.contentEquals("generateSecrets")) {
                        KeyPair keyPair = securityHelper.generateKey();
                        if (keyPair != null) {
                            securityHelper.persistKeyPair(keyPair);
                        } else {
                            throw new IllegalStateException("Key pair is empty");
                        }
                        String authSecret = securityHelper.generateAuthSecret();
                        if (authSecret != null && !authSecret.isEmpty()) {
                            securityHelper.persisAuthSecret(authSecret);
                        } else {
                            throw new IllegalStateException("Auth secret is empty");
                        }
                        result.success(null);
                    } else if (call.method.contentEquals("getKey")) {
                        String publicKeyBase64 = securityHelper.getPublicKeyBase64();
                        result.success(publicKeyBase64);
                    } else if (call.method.contentEquals("getAuthSecret")) {
                        String authSecret = securityHelper.getAuthSecretFromPersistedData();
                        result.success(authSecret);
                    } else if (call.method.contentEquals("decrypt")) {
                        String input = call.argument("input");
                        byte[] inputBytes = Base64.decode(input, Base64.DEFAULT);
                        String decryptMessage = securityHelper.decryptMessage(inputBytes);
                        result.success(decryptMessage);
                    }

                });
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleSendIntent(intent);
    }

    private void handleSendIntent(Intent intent) {
        String action = intent.getAction();
        String type = intent.getType();

        if (Intent.ACTION_SEND.equals(action) && type != null) {
            if (type.startsWith("text/")) {
                String text = intent.getStringExtra(Intent.EXTRA_TEXT);
                sharedData.put(SHARED_MIME_TYPE, type);
                sharedData.put(SHARED_TEXT, text);
            } else if (type.startsWith("application/") || type.startsWith("audio/") || type.startsWith("image/") || type.startsWith("video/")) {
                Uri uri = (Uri) Objects.requireNonNull(getIntent().getExtras()).get(Intent.EXTRA_STREAM);
                String text = intent.getStringExtra(Intent.EXTRA_TEXT);
                ShareHelper shareHelper = new ShareHelper();
                String uriPath = shareHelper.getFilePathForUri(this, uri);
                if(text != null && !text.isEmpty()){
                    sharedData.put(SHARED_TEXT, text);
                }
                sharedData.put(SHARED_MIME_TYPE, type);
                sharedData.put(SHARED_PATH, uriPath);
                sharedData.put(SHARED_FILE_NAME, shareHelper.getFileName());
            }
        }
    }

    private void shareFile(Object arguments) {
        @SuppressWarnings("unchecked")
        HashMap<String, String> argsMap = (HashMap<String, String>) arguments;
        String title = argsMap.get("title");
        String path = argsMap.get("path");
        String mimeType = argsMap.get("mimeType");
        String text = argsMap.get("text");

        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType(mimeType);
        File fileToShare = new File(path);
        Uri contentUri = FileProvider.getUriForFile(this, this.getPackageName() + ".fileProvider", fileToShare);
        if(!path.isEmpty()){
            shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
        }
        // add optional text
        if (!text.isEmpty()) shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        this.startActivity(Intent.createChooser(shareIntent, title));
    }

}
