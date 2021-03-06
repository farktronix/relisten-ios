//
//  TrackActions.swift
//  Relisten
//
//  Created by Alec Gorge on 5/24/18.
//  Copyright © 2018 Alec Gorge. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public class TrackActions {
    public static func showActionOptions(fromViewController vc: UIViewController, inView view: UIView, forTrack track: Track) {
        let duration = track.duration?.humanize()
        
        let a = UIAlertController(
            title: "\(track.title) \((duration == nil ? "" : "(\(duration!)" )))",
            message: "\(track.showInfo.source.display_date) • \(track.showInfo.artist.name)",
            preferredStyle: .actionSheet
        )
        
        let sourceView = ASFindClosestViewOfLayer(view.layer)!
        
        if let popoverController = a.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        a.addAction(UIAlertAction(title: "Play Now", style: .default, handler: { _ in
            self.play(track: track, fromViewController: vc)
        }))
        
        a.addAction(UIAlertAction(title: "Play Next", style: .default, handler: { _ in
            let ai = track.toAudioItem()
            RelistenApp.sharedApp.playbackController.playbackQueue.insert(ai, at: UInt(RelistenApp.sharedApp.playbackController.player.currentIndex) + UInt(1))
        }))
        
        a.addAction(UIAlertAction(title: "Add to End of Queue", style: .default, handler: { _ in
            let ai = track.toAudioItem()
            RelistenApp.sharedApp.playbackController.playbackQueue.append(ai)
        }))
        
        a.addAction(UIAlertAction(title: "Go to Show", style: .default, handler: { _ in
            SourcesViewController(artist: track.showInfo.artist, show: track.showInfo.show).presentIfNecessary(navigationController: RelistenApp.sharedApp.delegate.rootNavigationController)
        }))

        MyLibrary.shared.diskUsageForTrackURL(track: track.sourceTrack) { (size) in
            if let s = size {
                a.addAction(UIAlertAction(title: "Remove Downloaded File" + " (\(s.humanizeBytes()))", style: .default, handler: { _ in
                    DownloadManager.shared.delete(track: track)
                }))
            }
            else {
                a.addAction(UIAlertAction(title: "Make Available Offline", style: .default, handler: { _ in
                    let _ = DownloadManager.shared.download(track: track)
                }))
            }
            
            a.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
                let shareVc = ShareHelper.shareViewController(forTrack: track)

                if let popoverController = shareVc.popoverPresentationController {
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = sourceView.bounds
                }
                
                if RelistenApp.sharedApp.playbackController.hasBarBeenAdded {
                    RelistenApp.sharedApp.playbackController.viewController.present(shareVc, animated: true, completion: nil)
                }
                else {
                    vc.present(shareVc, animated: true, completion: nil)
                }
            }))
            
            a.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            }))
            
            if RelistenApp.sharedApp.playbackController.hasBarBeenAdded {
                RelistenApp.sharedApp.playbackController.viewController.present(a, animated: true, completion: nil)
            }
            else {
                vc.present(a, animated: true, completion: nil)
            }
        }
    }
    
    public static func play(trackAtIndexPath idx: IndexPath, inShow info: CompleteShowInformation, fromViewController vc: UIViewController) {
        play(trackAtIndex: UInt(info.source.flattenedIndex(forIndexPath: idx)), inShow: info, fromViewController: vc)
    }
    
    public static func play(track: Track, fromViewController vc: UIViewController) {
        var idx: UInt = 0
        var trackFound : Bool = false
        for set in track.showInfo.source.sets {
            if trackFound {
                break
            }
            for sourceTrack in set.tracks {
                if sourceTrack.id == track.id {
                    trackFound = true
                    break
                }
                
                idx = idx + 1
            }
        }
        
        play(trackAtIndex: idx, inShow: track.showInfo, fromViewController: vc)
    }
    
    public static func play(trackAtIndex: UInt, inShow info: CompleteShowInformation, fromViewController vc: UIViewController) {
        let items = info.source.toAudioItems(inShow: info.show, byArtist: info.artist)
        
        RelistenApp.sharedApp.playbackController.playbackQueue.clearAndReplace(with: items)
        
        RelistenApp.sharedApp.playbackController.displayMini(on: vc, completion: nil)
        
        RelistenApp.sharedApp.playbackController.player.playItem(at: trackAtIndex)
    }
}
