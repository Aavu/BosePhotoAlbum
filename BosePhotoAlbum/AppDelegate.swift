//
//  AppDelegate.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = .black
        UIToolbar.appearance().tintColor = .black
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        var isAlbum = false
        var mediaID = ""
        var userID = ""
        var albumName = ""
        var token = ""
        
        // sample abpa://userID@BosePhotoAlbum/?album=1&mediaID=123&albumName=myalbum&token=456
        if let host = url.host {
            if host == "BosePhotoAlbum" {
                if let usrID = url.user {
                    userID = usrID
                    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                        let params = components.queryItems else {
                            print("Invalid URL or album path missing")
                            return false
                    }
                    if let album = params.first(where: {$0.name == "album"})?.value {
                        if album == "1" {
                            isAlbum = true
                        } else {
                            isAlbum = false
                        }
                        print("isAlbum = \(isAlbum)")
                        if let ID = params.first(where: { $0.name == "mediaID" })?.value {
                            mediaID = ID
                            print("albumID = \(mediaID)")
                        } else {
                            return false
                        }
                        
                        if isAlbum {
                            if let name = params.first(where: { $0.name == "albumName" })?.value {
                                albumName = name.removingPercentEncoding ?? "nil"
                                print("albumName = \(albumName)")
                            } else {
                                return false
                            }
                        } else {
                            if let tk = params.first(where: { $0.name == "token" })?.value {
                                token = tk
                                print("token = \(token)")
                            } else {
                                return false
                            }
                        }
                        
                        // successfully parsed
                        let layout = UICollectionViewFlowLayout()
                        let homeVC = HomeViewController(collectionViewLayout: layout)
                        let navigationController = UINavigationController(rootViewController: homeVC)
                        if isAlbum {
                            // go to photos view controller
                            let photosVC = PhotosViewController(collectionViewLayout: layout)
                            photosVC.albumName = albumName
                            photosVC.albumID = mediaID
                            window?.rootViewController = navigationController
                            navigationController.pushViewController(photosVC, animated: true)
                        } else {
                            // go to image view controller
                            let imageVC = ImageViewController()
                            imageVC.imageID = mediaID
                            imageVC.token = token
                            imageVC.userID = userID
                            window?.rootViewController = navigationController
                            navigationController.pushViewController(imageVC, animated: true)
                        }
                        self.window?.makeKeyAndVisible()
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

