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
 * Copyright (C) 2016-2019 OX Software GmbH
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

fileprivate let INTENT_CHANNEL_NAME = "oxcoi.intent"

extension AppDelegate {
    
    fileprivate struct Constant {
        static let path = "path"
        static let text = "text"
        static let mimeType = "text/plain"
        static let keyPrefixShared = "shared"
    }

    fileprivate enum DataType: String {
        case url
        case text
        case file
    }

    internal func setupSharingMethodChannel() {
        guard let controller = window.rootViewController as? FlutterViewController else {
            return
        }

        let methodChannel = FlutterMethodChannel(name: INTENT_CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler {(call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case Method.Invite.InviteLink:
                if let startString = self.startString {
                    if !startString.isEmpty {
                        result(self.startString)
                        self.startString = nil
                        return
                    }
                }

            case Method.Sharing.SendSharedData:
                if let args = call.arguments as? [String: String] {
                    self.shareFile(arguments: args)
                }

            case Method.Sharing.GetSharedData:
                result(self.getSharedData())
                self.clearSharedData()
                return
            default:
                break
            }
            result(nil)
        }
    }

    private func shareFile(arguments: [String: String]) {
        var itemTemp: Any?

        if let path = arguments[Constant.path] {
            if !path.isEmpty {
                itemTemp = URL(fileURLWithPath: path)
            }
        }

        if let text = arguments[Constant.text] {
            if !text.isEmpty {
                itemTemp = text
            }
        }

        guard let item = itemTemp,
            let rootViewController = window.rootViewController as? FlutterViewController else {
            return
        }

        let activityController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        rootViewController.present(activityController, animated: true, completion: nil)

    }
    
    private func getSharedData() -> [String: Any?]? {
        var dict: [String: Any?]
        
        guard let userDefaults = UserDefaults(suiteName: SharedData.SuiteName),
            userDefaults.object(forKey: SharedData.DataType) != nil else {
            return nil
        }

        if userDefaults.object(forKey: SharedData.DataType) as? String == DataType.url.rawValue {
            dict = [SharedData.MimeType: Constant.mimeType, SharedData.Text: userDefaults.object(forKey: SharedData.Text)]
            return dict

        } else if userDefaults.object(forKey: SharedData.DataType) as? String == DataType.text.rawValue {
            dict = [SharedData.Text: userDefaults.object(forKey: SharedData.Text)]
            return dict

        } else if userDefaults.object(forKey: SharedData.DataType) as? String == DataType.file.rawValue {
            dict = [
                SharedData.MimeType: userDefaults.object(forKey: SharedData.MimeType),
                SharedData.Path: userDefaults.object(forKey: SharedData.Path),
                SharedData.FileName: userDefaults.object(forKey: SharedData.FileName)]
            return dict

        } else {
            return nil
        }
        
    }
    
    private func clearSharedData() {
        guard let userDefaults = UserDefaults(suiteName: SharedData.SuiteName) else {
            return
        }

        for key in userDefaults.dictionaryRepresentation().keys {
            if key.hasPrefix(Constant.keyPrefixShared) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}
