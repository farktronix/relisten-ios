//
//  UserPropertiesForShowNode.swift
//  Relisten
//
//  Created by Jacob Farkas on 7/24/18.
//  Copyright © 2018 Alec Gorge. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Observable

public class UserPropertiesForShowNode : ASCellNode, FavoriteButtonDelegate {
    public let source: SourceFull
    public let show: ShowWithSources
    public let artist: ArtistWithCounts
    private lazy var completeShowInformation = CompleteShowInformation(source: self.source, show: self.show, artist: self.artist)
    
    let isInMyShows = Observable(false)
    let isAvailableOffline = Observable(false)
    
    private var numberOfDownloadedTracks : Int = 0
    
    public var favoriteButtonAccessibilityLabel : String { get { return "Favorite Show" } }
    
    var disposal = Disposal()
    
    public init(source: SourceFull, inShow show: ShowWithSources, artist: ArtistWithCounts) {
        self.source = source
        self.show = show
        self.artist = artist
        
        favoriteButton = FavoriteButtonNode()
        
        shareButton = ASButtonNode()
        // TODO: Use a proper share icon
        shareButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        
        downloadText = ASTextNode("Download", textStyle: .footnote)
        downloadButton = ASButtonNode()
        downloadButton.setImage(#imageLiteral(resourceName: "download-outline"), for: .normal)
        
        super.init()
        
        self.backgroundColor = AppColors.primary
        
        automaticallyManagesSubnodes = true
        accessoryType = .none
        
        favoriteButton.currentlyFavorited = MyLibraryManager.shared.library.isShowInLibrary(show: show, byArtist: artist)
        favoriteButton.delegate = self
        
        setupLibraryObservers()
    }
    
    public let favoriteButton : FavoriteButtonNode
    public let shareButton : ASButtonNode
    public let downloadText : ASTextNode
    public let downloadButton : ASButtonNode
    
    public func didFavorite(currentlyFavorited : Bool) {
        if currentlyFavorited {
            MyLibraryManager.shared.addShow(show: self.completeShowInformation)
        } else {
            let _ = MyLibraryManager.shared.removeShow(show: self.completeShowInformation)
        }
    }
    
    private func setupLibraryObservers() {
        let library = MyLibraryManager.shared.library
        
        library.observeOfflineSources.observe { [weak self] (new, old) in
            guard let s = self else { return}
            s.isAvailableOffline.value = library.isSourceFullyAvailableOffline(s.source)
        }.add(to: &disposal)
        
        MyLibraryManager.shared.observeMyShows.observe { [weak self] (new, old) in
            guard let s = self else { return}
            s.isInMyShows.value = library.isShowInLibrary(show: s.show, byArtist: s.artist)
        }.add(to: &disposal)
        
        RelistenDownloadManager.shared.eventTrackFinishedDownloading.addHandler({ [weak self] track in
            guard let s = self else { return}
            if track.showInfo.source.id == s.source.id {
                MyLibraryManager.shared.library.diskUsageForSource(source: s.completeShowInformation) { (size, numberOfTracks) in
                    s.rebuildOfflineStatus(size, numberOfTracks: numberOfTracks)
                }
            }
        }).add(to: &disposal)
        
        RelistenDownloadManager.shared.eventTracksDeleted.addHandler({ [weak self] tracks in
            guard let s = self else { return}
            if tracks.any(match: { $0.showInfo.source.id == s.source.id }) {
                MyLibraryManager.shared.library.diskUsageForSource(source: s.completeShowInformation) { (size, numberOfTracks) in
                    s.rebuildOfflineStatus(size, numberOfTracks: numberOfTracks)
                }
            }
        }).add(to: &disposal)
        
        MyLibraryManager.shared.library.diskUsageForSource(source: completeShowInformation) { (size, numberOfTracks) in
            self.rebuildOfflineStatus(size, numberOfTracks: numberOfTracks)
        }
    }
    
    private func rebuildOfflineStatus(_ sourceSize: UInt64, numberOfTracks: Int) {
        var txt = "Make Show Available Offline"
        numberOfDownloadedTracks = numberOfTracks
        if numberOfTracks > 0 {
            let totalNumberOfTracks = source.tracksFlattened.count
            if numberOfTracks == totalNumberOfTracks {
                txt = "All songs downloaded (\(sourceSize.humanizeBytes()))"
            } else {
                txt = "\(numberOfTracks)/\(totalNumberOfTracks) song" + (totalNumberOfTracks > 1 ? "s" : "") + " (\(sourceSize.humanizeBytes()))"
            }
        }
        downloadText.attributedText = RelistenAttributedString(txt, textStyle: .footnote)
        self.setNeedsLayout()
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let buttonBar = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .start,
            alignItems: .center,
            children: ArrayNoNils(
                favoriteButton,
                SpacerNode(),
                shareButton,
                SpacerNode(),
                downloadButton
            )
        )
        buttonBar.style.alignSelf = .stretch
        
        let footnote = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .start,
            alignItems: .center,
            children: ArrayNoNils(
                SpacerNode(),
                downloadText
            )
        )
        footnote.style.alignSelf = .stretch
        
        let vert = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 8,
            justifyContent: .start,
            alignItems: .start,
            children: ArrayNoNils(
                buttonBar,
                numberOfDownloadedTracks > 0 ? footnote : nil
            )
        )
        vert.style.alignSelf = .stretch
        
        let l = ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(16, 16, 16, 16),
            child: vert
        )
        l.style.alignSelf = .stretch
        
        return l
    }
}