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

import android.util.Base64;

import com.google.crypto.tink.HybridDecrypt;
import com.google.crypto.tink.apps.webpush.WebPushHybridDecrypt;

import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.interfaces.ECPrivateKey;
import org.bouncycastle.jce.interfaces.ECPublicKey;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.spec.ECParameterSpec;
import org.bouncycastle.jce.spec.ECPrivateKeySpec;
import org.bouncycastle.jce.spec.ECPublicKeySpec;
import org.bouncycastle.math.ec.ECPoint;

import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.Security;
import java.security.spec.InvalidKeySpecException;


class SecurityHelper {

    private static final String CURVE_NAME = "secp256r1";
    private static final String KEY_ALGORITHM = "ECDH";

    SecurityHelper() {
        Security.removeProvider(BouncyCastleProvider.PROVIDER_NAME);
        Security.addProvider(new BouncyCastleProvider());
    }

    private ECPrivateKey getPrivateKeyFromPersistedData(String privateKeyBase64) {
        byte[] privateKeyBytes = Base64.decode(privateKeyBase64, Base64.URL_SAFE);
        BigInteger privateKeyD = new BigInteger(privateKeyBytes);

        ECParameterSpec ecParameterSpec = ECNamedCurveTable.getParameterSpec(CURVE_NAME);
        ECPrivateKeySpec privateKeySpec = new ECPrivateKeySpec(privateKeyD, ecParameterSpec);

        KeyFactory keyFactory;
        try {
            keyFactory = KeyFactory.getInstance(KEY_ALGORITHM);
            return (ECPrivateKey) keyFactory.generatePrivate(privateKeySpec);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            e.printStackTrace();
        }
        return null;
    }

    private ECPublicKey getPublicKeyFromBase64String(String publicKeyBase64) {
        byte[] publicKeyBytes = Base64.decode(publicKeyBase64, Base64.URL_SAFE);

        ECParameterSpec ecParameterSpec = ECNamedCurveTable.getParameterSpec(CURVE_NAME);
        ECPoint point = ecParameterSpec.getCurve().decodePoint(publicKeyBytes);
        ECPublicKeySpec pubSpec = new ECPublicKeySpec(point, ecParameterSpec);

        KeyFactory keyFactory;
        try {
            keyFactory = KeyFactory.getInstance(KEY_ALGORITHM);
            return (ECPublicKey) keyFactory.generatePublic(pubSpec);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            e.printStackTrace();
        }
        return null;
    }

    String decryptMessage(byte[] encryptedContent, String privateKeyBase64, String publicKeyBase64, String authBase64) {
        ECPrivateKey recipientPrivateKey = getPrivateKeyFromPersistedData(privateKeyBase64);
        ECPublicKey recipientPublicKey = getPublicKeyFromBase64String(publicKeyBase64);
        try {
            java.security.interfaces.ECPublicKey recipientPublicKeyAsJavaSecurity = (java.security.interfaces.ECPublicKey) recipientPublicKey;
            if (recipientPublicKey == null) {
                throw new IllegalStateException("Public key is null");
            }
            java.security.interfaces.ECPrivateKey recipientPrivateAsJavaSecurity = (java.security.interfaces.ECPrivateKey) recipientPrivateKey;
            byte[] authSecret = Base64.decode(authBase64, Base64.URL_SAFE);
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
