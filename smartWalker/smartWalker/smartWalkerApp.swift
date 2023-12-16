//
//  smartWalkerApp.swift
//  smartWalker
//
//  Created by Nikhil Chandra on 10/29/23.
//


import SwiftUI

import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    return true

  }

}


@main

struct smartWalkerApp: App {

  // register app delegate for Firebase setup

  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {

    WindowGroup {

      NavigationView {

        ContentView()

      }

    }

  }

}
