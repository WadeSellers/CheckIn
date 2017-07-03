//
//  AppDelegate.swift
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/7/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

import UIKit
import ObjectiveDDP
import NSLogger
import Fabric
import Crashlytics

//address to connect to meteor

let notifyAppBecameActive = "notifyAppBecameActive"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  //Setup KVO and DDP stuff here
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    UINavigationBar.appearance().barStyle = .BlackTranslucent
    
    Fabric.with([Crashlytics.self])
    Fabric.sharedSDK().debug = false
    //******************************
    //Be careful with Socket Rocket in Debug Mode
    //It will allow connection to any root cert
    //******************************
    Captuvo.sharedCaptuvoDevice().getCaptuvoSerialNumber()
    LogMessageRaw("Captuvo Firmware Version: \(Captuvo.sharedCaptuvoDevice().getCaptuvoSerialNumber())")
    LogMessageRaw("Captuvo Firmware Version: \(Captuvo.sharedCaptuvoDevice().getCaptuvoFirmwareRevision())")

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.reportConnection), name: MeteorClientDidConnectNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.reportDisconnection), name: MeteorClientDidDisconnectNotification, object: nil)

    //Sets up NSLogger's Logger Singleton
    LoggerStart(LoggerGetDefaultLogger())
    LogMessageRaw("NSLogger Singleton Created in AppDelegate.swift")

    return true
  }
  
  func reportConnection() {
    print("================> connected to server!")
  }
  
  func reportDisconnection() {
    print("================> disconnected from server!")
  }
  
  func didReceiveUpdate(notification:NSNotification) {
//    self.queueTableView.reloadData()
      print("did recieve meteor update in app delegate")
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
     NSNotificationCenter.defaultCenter().postNotificationName(notifyAppBecameActive, object: self)
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSNotificationCenter.defaultCenter().postNotificationName(notifyAppBecameActive, object: self)
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

