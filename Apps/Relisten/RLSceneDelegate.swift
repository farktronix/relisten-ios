//
//  RLSceneDelegate.swift
//  Relisten
//
//  Created by Jacob Farkas on 10/25/20.
//  Copyright © 2020 Alec Gorge. All rights reserved.
//

import UIKit
import RelistenShared

class RLSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    public var rootNavigationController: RelistenNavigationController! = nil
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: scene.coordinateSpace.bounds)
        
        window?.windowScene = scene
        let tabBarController = RelistenTabBarController(rootNavigationController)
        window?.rootViewController = tabBarController
        
        if rootNavigationController == nil {
            let artists = ArtistsViewController()
            let nav = RelistenNavigationController(rootViewController: artists)
            nav.tabBarItem = artists.tabBarItem
            
            rootNavigationController = nav
        }
        
        rootNavigationController.navigationBar.prefersLargeTitles = true
        rootNavigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColors.textOnPrimary]
        
        window?.makeKeyAndVisible()
        
        RelistenApp.sharedApp.playbackController.window = window
        
        RelistenApp.sharedApp.loadViews()
        RelistenApp.sharedApp.setupAppearance()
        
        let coloredAppearance = RelistenApp.sharedApp.coloredAppearance
        
        rootNavigationController.viewControllers.forEach({ tab in
            if let nav = tab as? UINavigationController {
                nav.navigationBar.barTintColor = AppColors.primary
                nav.navigationBar.backgroundColor = AppColors.primary
                nav.navigationBar.tintColor = AppColors.primary
                nav.navigationBar.standardAppearance = coloredAppearance
                nav.navigationBar.scrollEdgeAppearance = coloredAppearance
            }
        })
        tabBarController.tabBar.tintColor = AppColors.primary
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
