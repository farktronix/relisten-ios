//
//  RelistenModels.swift
//  Relisten
//
//  Created by Alec Gorge on 2/24/17.
//  Copyright © 2017 Alec Gorge. All rights reserved.
//

import Foundation

import SwiftyJSON

public typealias SwJSON = JSON

public class RelistenObject {
    public let id: Int
    public let created_at: Date
    public let updated_at: Date
    
    public let originalJSON: JSON
    
    public required init(json: JSON) throws {
        id = try json["id"].int.required()
        created_at = try json["created_at"].dateTime.required()
        updated_at = try json["updated_at"].dateTime.required()
        
        originalJSON = json
    }
    
    public func toPrettyJSONString() -> String {
        return originalJSON.rawString(.utf8, options: .prettyPrinted)!
    }
    
    public func toData() throws -> Data {
        return try originalJSON.rawData()
    }
}

public class SlimArtist : RelistenObject {
    public let musicbrainz_id: String
    public let featured: Int
    
    public let name: String
    public let slug: String
    
    public required init(json: JSON) throws {
        musicbrainz_id = try json["musicbrainz_id"].string.required()
        featured = try json["featured"].int.required()
        
        name = try json["name"].string.required()
        slug = try json["slug"].string.required()
        
        try super.init(json: json)
    }
}

public class SlimArtistWithFeatures : SlimArtist {
    public let features: Features
    
    public required init(json: JSON) throws {
        features = try Features(json: json["features"])
        
        try super.init(json: json)
    }
}

public class Artist : SlimArtistWithFeatures {
    public let upstream_sources: [ArtistUpstreamSource]
    
    public required init(json: JSON) throws {
        upstream_sources = try json["upstream_sources"].arrayValue.map({ return try ArtistUpstreamSource(json: $0) })

        try super.init(json: json)
    }
}

public class ArtistWithCounts : Artist {
    public let show_count: Int
    public let source_count: Int
    
    public required init(json: JSON) throws {
        show_count = try json["show_count"].int.required()
        source_count = try json["source_count"].int.required()
        
        try super.init(json: json)
    }
}

public struct Features {
    public let id : Int
    public let descriptions : Bool
    public let eras : Bool
    public let multiple_sources : Bool
    public let reviews : Bool
    public let ratings : Bool
    public let tours : Bool
    public let taper_notes : Bool
    public let source_information : Bool
    public let sets : Bool
    public let per_show_venues : Bool
    public let per_source_venues : Bool
    public let venue_coords : Bool
    public let songs : Bool
    public let years : Bool
    public let track_md5s : Bool
    public let review_titles : Bool
    public let jam_charts : Bool
    public let setlist_data_incomplete : Bool
    public let artist_id : Int
    public let track_names : Bool
    public let venue_past_names : Bool
    public let reviews_have_ratings : Bool
    public let track_durations : Bool
    public let can_have_flac : Bool

    public init(json: JSON) throws {
        id = try json["id"].int.required()
        descriptions = try json["descriptions"].bool.required()
        eras = try json["eras"].bool.required()
        multiple_sources = try json["multiple_sources"].bool.required()
        reviews = try json["reviews"].bool.required()
        ratings = try json["ratings"].bool.required()
        tours = try json["tours"].bool.required()
        taper_notes = try json["taper_notes"].bool.required()
        source_information = try json["source_information"].bool.required()
        sets = try json["sets"].bool.required()
        per_show_venues = try json["per_show_venues"].bool.required()
        per_source_venues = try json["per_source_venues"].bool.required()
        venue_coords = try json["venue_coords"].bool.required()
        songs = try json["songs"].bool.required()
        years = try json["years"].bool.required()
        track_md5s = try json["track_md5s"].bool.required()
        review_titles = try json["review_titles"].bool.required()
        jam_charts = try json["jam_charts"].bool.required()
        setlist_data_incomplete = try json["setlist_data_incomplete"].bool.required()
        artist_id = try json["artist_id"].int.required()
        track_names = try json["track_names"].bool.required()
        venue_past_names = try json["venue_past_names"].bool.required()
        reviews_have_ratings = try json["reviews_have_ratings"].bool.required()
        track_durations = try json["track_durations"].bool.required()
        can_have_flac = try json["can_have_flac"].bool.required()
    }
}

public class SlimArtistUpstreamSource {
    public let upstream_source_id: Int
    public let upstream_identifier: String?
    
    public required init(json: JSON) throws {
        upstream_source_id = try json["upstream_source_id"].int.required()
        upstream_identifier = json["upstream_identifier"].string
    }
}

public class ArtistUpstreamSource : SlimArtistUpstreamSource {
    public let artist_id: Int
    public let upstream_source: UpstreamSource?
    
    public required init(json: JSON) throws {
        artist_id = try json["artist_id"].int.required()
        
        upstream_source = !json["upstream_source"].isEmpty ? try UpstreamSource(json: json["upstream_source"]) : nil
        
        try super.init(json: json)
    }
}

public struct UpstreamSource {
    public let id : Int
    public let name : String
    public let url : String
    public let description : String
    public let credit_line : String
    
    public init(json: JSON) throws {
        id = try json["id"].int.required()
        name = try json["name"].string.required()
        url = try json["url"].string.required()
        description = try json["description"].string.required()
        credit_line = try json["credit_line"].string.required()
    }
}
