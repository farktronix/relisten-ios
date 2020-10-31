//
//  RelistenApp.swift
//  RelistenShared
//
//  Created by Jacob Farkas on 7/25/18.
//  Copyright © 2018 Alec Gorge. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Observable
import RealmSwift
import Crashlytics

public protocol RelistenAppDelegate {
    var rootNavigationController: RelistenNavigationController! { get }
    
    var appIcon : UIImage { get }
    
    var isDummyDelegate : Bool { get }
}

public class RelistenApp {
    public static let sharedApp = RelistenApp(delegate: RelistenDummyAppDelegate())
        
    @MutableObservable private var pShakeToReportBugEnabled:Bool = true
    public var shakeToReportBugEnabled:MutableObservable<Bool> { return _pShakeToReportBugEnabled }
    
    public var playbackController : PlaybackController! { didSet {
            if oldValue != nil {
                playbackController.inheritObservables(fromPlaybackController: oldValue)
            }
        }
    }
    
    public var delegate : RelistenAppDelegate
    
    public static let logDirectory : String = {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                   FileManager.SearchPathDomainMask.userDomainMask,
                                                   true).first! + "/Logs"
    }()
    
    public static let appName : String = {
        guard let retval = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            return "Relisten"
        }
        return retval
    }()
    
    public static let appVersion : String = {
        guard let retval = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "1.0"
        }
        return retval
    }()
    
    public static let appBuildVersion : String = {
        guard let retval = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return "0"
        }
        return retval
    }()
    
    public var appIcon : UIImage {
        get {
            return delegate.appIcon
        }
    }
    
    public var launchCount : Int {
        if let launchCount = UserDefaults.standard.object(forKey: launchCountKey) as! Int? {
            return launchCount
        }
        return 0
    }
    
    public var crashlyticsUserIdentifier : String {
        get {
            if let retval = UserDefaults.standard.object(forKey: crashlyticsUserIdentifierKey) as! String? {
                return retval
            } else {
                let userIdentifier = UUID().uuidString
                UserDefaults.standard.set(userIdentifier, forKey: crashlyticsUserIdentifierKey)
                return userIdentifier
            }
        }
    }
    
    let bugReportingKey = "EnableBugReporting"
    let launchCountKey = "LaunchCount"
    let crashlyticsUserIdentifierKey = "UserIdentifier"
    
    var disposal = Disposal()
    public init(delegate: RelistenAppDelegate) {
        MyLibrary.migrateRealmDatabase()
        self.delegate = delegate
        
        if let enableBugReporting = UserDefaults.standard.object(forKey: bugReportingKey) as! Bool? {
            pShakeToReportBugEnabled = enableBugReporting
        }
        
        if let launchCount = UserDefaults.standard.object(forKey: launchCountKey) as! Int? {
            UserDefaults.standard.set(launchCount + 1, forKey: launchCountKey)
        } else {
            UserDefaults.standard.set(1, forKey: launchCountKey)
        }
        
        DownloadManager.shared.dataSource = MyLibrary.shared
        
        shakeToReportBugEnabled.observe { (new, _) in
            UserDefaults.standard.set(new, forKey: self.bugReportingKey)
        }.add(to: &disposal)
    }
    
    public func sharedSetup() {
        playbackController = PlaybackController()
        
        DispatchQueue.main.async {
            let _ = DownloadManager.shared
        }
        
        setupWormholy()
        UserFeedback.shared.setup()
        
        let userIdentifier = self.crashlyticsUserIdentifier
        LogDebug("Setting Crashlytics user identifier to \(userIdentifier)")
        Crashlytics.sharedInstance().setUserIdentifier(userIdentifier)
        
        // Initialize CarPlay
        CarPlayController.shared.setup()
    }
    
    public func loadViews() {
        AppColorObserver.observe { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.setupAppearance()
            }
        }.add(to: &disposal)
        
        playbackController.viewDidLoad()
    }
    
    public var coloredAppearance : UINavigationBarAppearance {
        get {
            let coloredAppearance = UINavigationBarAppearance()
            coloredAppearance.configureWithOpaqueBackground()
            coloredAppearance.backgroundColor = AppColors.primary
            coloredAppearance.titleTextAttributes = [.foregroundColor: AppColors.textOnPrimary]
            coloredAppearance.largeTitleTextAttributes = [.foregroundColor: AppColors.textOnPrimary]
            return coloredAppearance
        }
    }
    
    public func setupAppearance() {
        let _ = RatingViewStubBounds
        
        UINavigationBar.appearance().barTintColor = AppColors.primary
        UINavigationBar.appearance().backgroundColor = AppColors.textOnPrimary
        UINavigationBar.appearance().tintColor = AppColors.textOnPrimary
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColors.textOnPrimary]
        
        let coloredAppearance = self.coloredAppearance
               
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UIToolbar.appearance().backgroundColor = AppColors.primary
        UIToolbar.appearance().tintColor = AppColors.textOnPrimary
        
        UIButton.appearance().tintColor = AppColors.primary
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = AppColors.textOnPrimary
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.textOnPrimary], for: .normal)
        
        UISegmentedControl.appearance().tintColor = AppColors.primary
        UITabBar.appearance().tintColor = AppColors.primary
        
        let sutf = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        sutf.defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        sutf.tintColor = UIColor.white.withAlphaComponent(0.8)
        
        let sbbi = UISegmentedControl.appearance(whenContainedInInstancesOf: [UISearchBar.self])

        sbbi.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.primary], for: .selected)
        sbbi.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.textOnPrimary], for: .normal)
        
        sbbi.tintColor = AppColors.textOnPrimary
        sbbi.backgroundColor = AppColors.primary
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = AppColors.textOnPrimary
        
        playbackController?.viewController.applyColors(AppColors.playerColors)
    }
}

public extension RelistenAppDelegate {
    var isDummyDelegate : Bool { get { return false } }
}

public class RelistenDummyAppDelegate : RelistenAppDelegate {
    public var isDummyDelegate = true
    
    public var rootNavigationController: RelistenNavigationController! {
        get {
            fatalError("An application delegate hasn't been set yet!")
        }
    }
    
    public var appIcon : UIImage {
        get {
            fatalError("An application delegate hasn't been set yet!")
        }
    }
}
