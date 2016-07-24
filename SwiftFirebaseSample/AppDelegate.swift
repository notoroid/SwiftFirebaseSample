//
//  AppDelegate.swift
//  SwiftFirebaseSample
//
//  Created by 能登 要 on 2016/07/24.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var UUID: String! = NSUUID().UUIDString

    var deviceKeyName: String! = "Devices"
    var inviteKeyName: String! = "DeviceInvites"
    var textFieldKeyName: String! = "text"
    var UUIDKeyName: String! = "UUID"

    var rootRef: FIRDatabaseReference? = nil
    var textFieldRef: FIRDatabaseReference? = nil


    override init() {
        // Firebase Init
        FIRApp.configure()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        rootRef = FIRDatabase.database().reference()

        textFieldRef = rootRef?.child(deviceKeyName).child(UUID).child(textFieldKeyName)
        textFieldRef?.setValue("Firebaseのサンプル")

        return true
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }


}
