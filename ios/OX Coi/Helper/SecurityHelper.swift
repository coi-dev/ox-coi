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

import Foundation
import Tink
import CryptoKit
import GMEllipticCurveCrypto

class SecurityHelper {
    
    typealias PrivateKeyType = (privateKey: P256.KeyAgreement.PrivateKey, privateKeyData: Data)
    typealias PublicKeyType = (publicKey: P256.KeyAgreement.PublicKey, publicKeyData: Data)

    var enryptedMessage: EncryptedPushMessage?
    
    init(message: [String: String]) throws {
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            self.enryptedMessage = try JSONDecoder().decode(EncryptedPushMessage.self, from: data)

        } catch {
            throw SecurityHelperError.initFailed(error: error.localizedDescription)
        }
    }
    
    func getDecryptedMessage() throws -> String? {
        do {
            guard let enryptedMessage = enryptedMessage else {
                    return nil
            }

            let privateKeyType = try privateKey(from: enryptedMessage.privateKeyBase64)
            let publicKeyType = try publicKey(from: enryptedMessage.publicKeyBase64)

            guard let authSecretData = Data(base64Encoded: enryptedMessage.authBase64, options: .ignoreUnknownCharacters),
                let authSecret = String(data: authSecretData, encoding: .utf8) else {
                    throw SecurityHelperError.authSecretGenerationFailed(error: "Could not generate Data or String from authBase64: \(enryptedMessage.authBase64)")
            }
            
//            let keysetHandle = TINKKeysetHandle()
//            let hybridDecrypt: TINKHybridDecrypt = TINKHybridDecryptFactory

        } catch {
            throw SecurityHelperError.messageDecryptionFailed(error: error.localizedDescription)
        }

        return nil
    }
    
    func privateKey(from base64EncodedKey: String) throws -> PrivateKeyType {
        do {
            guard let data = Data(base64Encoded: base64EncodedKey, options: .ignoreUnknownCharacters) else {
                throw SecurityHelperError.privateKeyGenerationFailed(error: "Could not generate Data from base64EncodedKey: \(base64EncodedKey)")
            }

            var result: PrivateKeyType
            result.privateKey = try P256.KeyAgreement.PrivateKey(rawRepresentation: data)
            result.privateKeyData = data
            
            return result

        } catch {
            throw SecurityHelperError.privateKeyGenerationFailed(error: error.localizedDescription)
        }
    }
    
    func publicKey(from base64EncodedKey: String) throws -> PublicKeyType {
        do {
            guard let data = Data(base64Encoded: base64EncodedKey, options: .ignoreUnknownCharacters) else {
                throw SecurityHelperError.publicKeyGenerationFailed(error: "Could not generate Data from base64EncodedKey: \(base64EncodedKey)")
            }
            
            var result: PublicKeyType
            result.publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: data)
            result.publicKeyData = data
            
            return result

        } catch {
            throw SecurityHelperError.publicKeyGenerationFailed(error: error.localizedDescription)
        }
    }

}

extension String {
    var base64Decoded: String? {
        get {
            if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters),
                let decodedString = String(data: data, encoding: .utf8) {
                return decodedString
            }
            return nil
        }
    }
}

struct EncryptedPushMessage: Decodable {
    let encryptedBase64Content: String
    let privateKeyBase64: String
    let publicKeyBase64: String
    let authBase64: String
}

enum SecurityHelperError: Error {
    case initFailed(error: String)
    case messageDecryptionFailed(error: String)
    case authSecretGenerationFailed(error: String)
    case privateKeyGenerationFailed(error: String)
    case publicKeyGenerationFailed(error: String)
    case decryptMessageFailed(error: String)
}
    
