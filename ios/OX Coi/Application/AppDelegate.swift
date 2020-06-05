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
import Firebase

@UIApplicationMain
@objc
class AppDelegate: FlutterAppDelegate {

    private var sharedData: [String: String]?
    var startString: String?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NSLog("[AppDelegate] didFinishLaunchingWithOptions")
        UIApplication.setupLogging()
        UIApplication.setupFirebase()

        GeneratedPluginRegistrant.register(with: self)

//        application.setMinimumBackgroundFetchInterval(60 * 5)
        setupSharingMethodChannel()
        setupSecurityMethodChannel()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        NSLog("[AppDelegate] open url")
        startString = url.absoluteString
        setupSharingMethodChannel()
        
        return true
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("[AppDelegate] didRegisterForRemoteNotificationsWithDeviceToken")
        Messaging.messaging().apnsToken = deviceToken
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("[AppDelegate] applicationDidEnterBackground")
        if UserDefaults.applicationShouldTerminate {
            UserDefaults.applicationShouldTerminate = false
            let sel = Selector(("terminateWithSuccess"))

            if application.responds(to: sel) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    application.perform(sel)
                }
            }
        }
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("[AppDelegate] applicationDidBecomeActive")
        // https://github.com/flutter/flutter/issues/47203#issuecomment-590834018
        signal(SIGPIPE, SIG_IGN)
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("[AppDelegate] applicationWillEnterForeground")
        signal(SIGPIPE, SIG_IGN)
    }

}
