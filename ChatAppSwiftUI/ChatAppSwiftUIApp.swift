//
//  ChatAppSwiftUIApp.swift
//  ChatAppSwiftUI
//
//  Created by Rodrigo Leyva on 11/9/21.
//

import SwiftUI
import Firebase

@main


struct ChatAppSwiftUIApp: App {
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//class AppDelegate: NSObject,UIApplicationDelegate{
//
//    func application(_ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions:
//            [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Intial Firebase
//        FirebaseApp.configure()
//
//
//        return true
//      }
//
//
//}
