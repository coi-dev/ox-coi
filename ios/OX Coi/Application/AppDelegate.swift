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

import Flutter
import UIKit

@UIApplicationMain
@objc
class AppDelegate: FlutterAppDelegate {

    private let INTENT_CHANNEL_NAME = "oxcoi.intent"
    private var sharedData: [String: String]?
    var startString: String?

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.setupLogging()

        GeneratedPluginRegistrant.register(with: self)
        setupSharingMethodChannel()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        startString = url.absoluteString
        setupSharingMethodChannel()
        return true
    }

    private func setupSharingMethodChannel() {
        guard let controller = window.rootViewController as? FlutterViewController else {
            return
        }
        let methodChannel = FlutterMethodChannel(name: INTENT_CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler {(call: FlutterMethodCall, result: FlutterResult) -> Void in
            if call.method.contains(Method.Invite.InviteLink) {
                if self.startString != nil || self.startString != "" {
                    result(self.startString)
                    self.startString = nil
                } else {
                    result(nil)
                }
            } else if call.method.contains(Method.Sharing.SendSharedData) {
                guard let args = call.arguments as? [String: String] else {
                    result(nil)
                    return
                }
                self.shareFile(arguments: args)
                result(nil)
            }
        }
    }
    
    private func shareFile(arguments: [String: String]) {
        let path = arguments["path"]
        let text = arguments["text"]
        var itemTemp: Any?
        
        if path != "" {
            itemTemp = URL(fileURLWithPath: path!)
        }
        if text != "" {
            itemTemp = text
        }
        guard let item = itemTemp else {
            return
        }
        guard let controller = window.rootViewController as? FlutterViewController else {
            return
        }
        let ac = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        controller.present(ac, animated: true, completion: nil)
        
    }

}
