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

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Base64;

import com.google.crypto.tink.HybridDecrypt;
import com.google.crypto.tink.apps.webpush.WebPushHybridDecrypt;

import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.interfaces.ECPrivateKey;
import org.bouncycastle.jce.interfaces.ECPublicKey;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.provider.asymmetric.ec.KeyPairGenerator;
import org.bouncycastle.jce.spec.ECParameterSpec;
import org.bouncycastle.jce.spec.ECPrivateKeySpec;
import org.bouncycastle.jce.spec.ECPublicKeySpec;
import org.bouncycastle.math.ec.ECPoint;

import java.math.BigInteger;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.Security;
import java.security.spec.ECGenParameterSpec;
import java.security.spec.InvalidKeySpecException;


class SecurityHelper {

    private static final String KEY_PUSH_PRIVATE = "KEY_PUSH_PRIVATE";
    private static final String KEY_PUSH_PUBLIC = "KEY_PUSH_PUBLIC";
    private static final String KEY_PUSH_AUTH = "KEY_PUSH_AUTH";
    private static final String CURVE_NAME = "secp256r1";
    private static final String KEY_ALGORITHM = "ECDH";

    private Activity activity;

    SecurityHelper(Activity activity) {
        Security.removeProvider(BouncyCastleProvider.PROVIDER_NAME);
        Security.addProvider(new BouncyCastleProvider());
        this.activity = activity;
    }

    String getPublicKeyBase64() {
        ECPublicKey publicKey = getPublicKeyFromPersistedData();
        if (publicKey == null) {
            return null;
        }
        return Base64.encodeToString(publicKey.getQ().getEncoded(), Base64.URL_SAFE);
    }

    KeyPair generateKey() {
        ECGenParameterSpec params = new ECGenParameterSpec(CURVE_NAME);
        KeyPairGenerator generator = new KeyPairGenerator.ECDH();
        try {
            generator.initialize(params, new SecureRandom());
        } catch (InvalidAlgorithmParameterException e) {
            e.printStackTrace();
        }
        return generator.generateKeyPair();
    }

    String generateAuthSecret() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[16];
        random.nextBytes(bytes);
        return Base64.encodeToString(bytes, Base64.URL_SAFE);
    }

    void persistKeyPair(KeyPair keyPair) {
        ECPublicKey ecPublicKey = (ECPublicKey) keyPair.getPublic();
        ECPrivateKey ecPrivateKey = (ECPrivateKey) keyPair.getPrivate();
        String publicKeyBase64 = Base64.encodeToString(ecPublicKey.getQ().getEncoded(), Base64.URL_SAFE);
        String privateKeyBase64 = Base64.encodeToString(ecPrivateKey.getD().toByteArray(), Base64.URL_SAFE);
        SharedPreferences sharedPref = activity.getPreferences(Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putString(KEY_PUSH_PRIVATE, privateKeyBase64);
        editor.putString(KEY_PUSH_PUBLIC, publicKeyBase64);
        editor.apply();
    }

    void persisAuthSecret(String authSecret) {
        SharedPreferences sharedPref = activity.getPreferences(Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putString(KEY_PUSH_AUTH, authSecret);
        editor.apply();
    }

    private ECPrivateKey getPrivateKeyFromPersistedData() {
        SharedPreferences sharedPref = activity.getPreferences(Context.MODE_PRIVATE);
        String privateKeyBase64 = sharedPref.getString(KEY_PUSH_PRIVATE, "");
        byte[] privateKeyBytes = Base64.decode(privateKeyBase64, Base64.URL_SAFE);
        BigInteger privateKeyD = new BigInteger(privateKeyBytes);

        ECParameterSpec ecParameterSpec = ECNamedCurveTable.getParameterSpec(CURVE_NAME);
        ECPrivateKeySpec privateKeySpec = new ECPrivateKeySpec(privateKeyD, ecParameterSpec);

        KeyFactory keyFactory;
        try {
            keyFactory = KeyFactory.getInstance(KEY_ALGORITHM);
            return (ECPrivateKey) keyFactory.generatePrivate(privateKeySpec);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (InvalidKeySpecException e) {
            e.printStackTrace();
        }
        return null;
    }

    private ECPublicKey getPublicKeyFromPersistedData() {
        SharedPreferences sharedPref = activity.getPreferences(Context.MODE_PRIVATE);
        String publicKeyBase64 = sharedPref.getString(KEY_PUSH_PUBLIC, "");
        byte[] publicKeyBytes = Base64.decode(publicKeyBase64, Base64.URL_SAFE);

        ECParameterSpec ecParameterSpec = ECNamedCurveTable.getParameterSpec(CURVE_NAME);
        ECPoint point = ecParameterSpec.getCurve().decodePoint(publicKeyBytes);
        ECPublicKeySpec pubSpec = new ECPublicKeySpec(point, ecParameterSpec);

        KeyFactory keyFactory;
        try {
            keyFactory = KeyFactory.getInstance(KEY_ALGORITHM);
            return (ECPublicKey) keyFactory.generatePublic(pubSpec);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (InvalidKeySpecException e) {
            e.printStackTrace();
        }
        return null;
    }

    String getAuthSecretFromPersistedData() {
        SharedPreferences sharedPref = activity.getPreferences(Context.MODE_PRIVATE);
        return sharedPref.getString(KEY_PUSH_AUTH, "");
    }

    String decryptMessage(byte[] encryptedContent) {
        ECPrivateKey recipientPrivateKey = getPrivateKeyFromPersistedData();
        ECPublicKey recipientPublicKey = getPublicKeyFromPersistedData();
        try {
            java.security.interfaces.ECPublicKey recipientPublicKeyAsJavaSecurity = (java.security.interfaces.ECPublicKey) recipientPublicKey;
            if (recipientPublicKey == null) {
                throw new IllegalStateException("Public key is null");
            }
            java.security.interfaces.ECPrivateKey recipientPrivateAsJavaSecurity = (java.security.interfaces.ECPrivateKey) recipientPrivateKey;
            byte[] authSecret = Base64.decode(getAuthSecretFromPersistedData(), Base64.URL_SAFE);
            HybridDecrypt hybridDecrypt = new WebPushHybridDecrypt.Builder()
                    .withAuthSecret(authSecret)
                    .withRecipientPublicKey(recipientPublicKeyAsJavaSecurity)
                    .withRecipientPrivateKey(recipientPrivateAsJavaSecurity)
                    .build();
            byte[] plaintext = hybridDecrypt.decrypt(encryptedContent, null/* contextInfo, must be null */);
            return new String(plaintext);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
