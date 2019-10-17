//
//  AppDelegate.swift
//  QiChartsDemo
//
//  Created by wangdacheng on 2019/10/14.
//  Copyright © 2019 qishare. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let homeNav = UINavigationController(rootViewController: ChartViewController())
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = homeNav
        window?.makeKeyAndVisible()
        
        return true;
    }
    
}

