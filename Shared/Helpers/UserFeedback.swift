//
//  UserFeedback.swift
//  RelistenShared
//
//  Created by Jacob Farkas on 8/23/18.
//  Copyright © 2018 Alec Gorge. All rights reserved.
//

import Foundation
import PinpointKit
import CWStatusBarNotification
import RealmSwift
import RealmConverter

public class UserFeedback  {
    static public let shared = UserFeedback()
    
    let pinpointKit : PinpointKit
    var screenshotDetector : ScreenshotDetector?
    var currentNotification : CWStatusBarNotification?
    
    public init() {
        let feedbackConfig = FeedbackConfiguration(recipients: ["ios@relisten.net"])
        let config = Configuration(logCollector: RelistenLogCollector(), feedbackConfiguration: feedbackConfig)
        pinpointKit = PinpointKit(configuration: config)
    }
    
    public func setup() {
        screenshotDetector = ScreenshotDetector(delegate: self)
    }
    
    public func presentFeedbackView(from vc: UIViewController? = nil, screenshot : UIImage? = nil) {
        guard let viewController = vc ?? RelistenApp.sharedApp.delegate.rootNavigationController else { return }
        
        if let screenshot = screenshot {
            currentNotification?.dismiss()
            pinpointKit.show(from: viewController, screenshot: screenshot)
        } else {
            currentNotification?.dismiss() {
                // If I grab the screenshot immediately there's still a tiny line from the notification animating away. If I let the runloop run for just a bit longer then the screenshot doesn't pick up that turd.
                DispatchQueue.main.async {
                    self.pinpointKit.show(from: viewController, screenshot: Screenshotter.takeScreenshot())
                }
            }
        }
    }
    
    public func requestUserFeedback(from vc : UIViewController? = nil, screenshot : UIImage? = nil) {
        currentNotification?.dismiss()
        
        let notification = CWStatusBarNotification()
        notification.notificationTappedBlock = {
            self.presentFeedbackView(screenshot: screenshot)
        }
        notification.notificationStyle = .navigationBarNotification
        notification.notificationLabelBackgroundColor = AppColors.highlight
        notification.notificationLabelFont = UIFont.preferredFont(forTextStyle: .headline)
        
        currentNotification = notification
        currentNotification?.display(withMessage: "🐞 Tap here to report a bug 🐞", forDuration: 3.0)
    }
}

extension UserFeedback : ScreenshotDetectorDelegate {
    public func screenshotDetector(_ screenshotDetector: ScreenshotDetector, didDetect screenshot: UIImage) {
        requestUserFeedback(screenshot: screenshot)
    }
    
    public func screenshotDetector(_ screenshotDetector: ScreenshotDetector, didFailWith error: ScreenshotDetector.Error) {
        
    }
}

class RelistenLogCollector : LogCollector {
    public func retrieveLogs() -> [String] {
        var retval : [String] = []
        let fm = FileManager.default
        let logDir = RelistenApp.sharedApp.logDirectory
        
        // List offline tracks
        do {
            var isDir : ObjCBool = false
            if fm.fileExists(atPath: DownloadManager.shared.downloadFolder, isDirectory: &isDir), isDir.boolValue {
                retval.append("======= Offline Files =======")
                for file in try fm.contentsOfDirectory(atPath: DownloadManager.shared.downloadFolder) {
                    retval.append("\t\(file)")
                }
                retval.append("======= End Offline Files =======\n\n")
            }
        } catch {
            LogWarn("Error enumerating downloaded tracks: \(error)")
        }
        
        // Dump the database
        do {
            let realm = try Realm()
            let exporter = CSVDataExporter(realm: realm.rlmRealm)
            if let tmpPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                let exportPath = tmpPath + "/" + String(Date().timeIntervalSinceReferenceDate)
                try fm.createDirectory(atPath: exportPath, withIntermediateDirectories: true, attributes: nil)
                // Export the database
                try exporter.export(toFolderAtPath: exportPath)
                // The exporter creates a bunch of files, one for each object type in the database
                retval.append("======= Database Contents =======")
                for filename in try fm.contentsOfDirectory(atPath: exportPath) {
                    let curObjectString = try String(contentsOfFile: exportPath + "/" + filename)
                    retval.append("---- \(filename) ----\n")
                    retval.append(curObjectString + "\n")
                    retval.append("---- END \(filename) ----\n")
                }
                retval.append("======= End Database Contents =======\n\n")
                
                // Clean up after ourselves
                try fm.removeItem(atPath: exportPath)
            }
        } catch {
            LogWarn("Exception while exporting database: \(error)")
        }
        
        
        // Grab the latest log file
        autoreleasepool {
            do {
                if let logFile = try fm.contentsOfDirectory(atPath: logDir).sorted(by: { return $0 > $1 }).first {
                    let data = try String(contentsOfFile: logDir + "/" + logFile, encoding: .utf8)
                    retval.append("======= Latest Log File (\(logFile)) =======")
                    retval.append(contentsOf: data.components(separatedBy: .newlines))
                    retval.append("======= End Latest Log File (\(logFile)) =======\n\n")
                }
            } catch {
                LogWarn("Couldn't read log file at \(logDir): \(error)")
            }
        }
        
        return retval
    }
}
