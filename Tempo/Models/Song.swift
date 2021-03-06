//
//  Song.swift
//  Tempo
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke

let spotifyAPIBaseURL = URL(string: "https://api.spotify.com/v1/tracks/")
let SongDidDownloadArtworkNotification = "SongDidDownloadArtwork"

class Song: NSObject {
	var title = ""
	var artist = ""
	var album = ""
	var largeArtworkURL: URL?
	var smallArtworkURL: URL?
	
	fileprivate var largeArtwork: UIImage?
	func fetchArtwork() -> UIImage? {
		if largeArtworkURL != nil && largeArtwork == nil {
			Shared.imageCache.fetch(URL: largeArtworkURL!).onSuccess {
				self.largeArtwork = $0
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: SongDidDownloadArtworkNotification), object: self)
			}
			
		}
		return largeArtwork
	}
	
	var spotifyID: String = ""
	var previewURL: URL!
	
	init(songID: String) {
		super.init()
		spotifyID = songID
		setSongID(songID)
	}
	
	convenience init(spotifyURI: String) {
		let components = spotifyURI.components(separatedBy: ":")
		let id = components.last ?? ""
		self.init(songID: id)
	}
	
	init(responseDictionary: [String: AnyObject]) {
		super.init()
		initializeFromResponseDictionary(responseDictionary)
	}
	
	init(json: SwiftyJSON.JSON) {
		super.init()
		initializeFromResponse(json)
	}
	
	fileprivate func initializeFromResponseDictionary(_ response: [String: AnyObject]) {
		initializeFromResponse(JSON(response))
	}
	
	fileprivate func initializeFromResponse(_ json: SwiftyJSON.JSON) {
		if let track = json["name"].string {
			title = track
			let preview = json["preview_url"].stringValue
			previewURL = URL(string: preview)
			let artists = json["artists"].arrayValue
			if artists.count > 1 {
				artist = artists
						.map({ $0["name"].string! })
						.reduce("", { $0 + ", " + $1})
						.chopPrefix(2)
			} else {
				artist = artists.first?["name"].string ?? "Unknown Artist"
			}
			
			let albums = json["album"].dictionaryValue
			album = albums["name"]?.string ?? "Unknown Album"
			
			let images = albums["images"]?.arrayValue ?? []
			if images.count > 0 {
				var firstImage = images[images.count - 1].dictionaryValue
				smallArtworkURL = URL(string: firstImage["url"]?.stringValue ?? "")
				
				firstImage = images[0].dictionaryValue
				largeArtworkURL = URL(string: firstImage["url"]?.stringValue ?? "")
			}
			spotifyID = json["id"].stringValue
		} else if let track = json["track"].string {
			title = track
			artist = json["artist"].stringValue
			spotifyID = json["id"].stringValue
		}
	}
	
	fileprivate func setSongID(_ id: String) {

		if let url = URL(string: spotifyID, relativeTo: spotifyAPIBaseURL),
		let data = try? Data(contentsOf: url) {
			let json = JSON(data: data)
			initializeFromResponse(json)
		}
	}
	
	override init() {
		assertionFailure("use init(songID:)")
	}
	
	override var description: String {
		return "Song: \(title) \(artist)"
	}
	
	func equals(other: Song) -> Bool {
		return spotifyID == other.spotifyID
	}
}
