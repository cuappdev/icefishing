//
//  User.swift
//  Tempo
//
//  Created by Annie Cheng on 3/17/15.
//  Copyright (c) 2015 Annie Cheng. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject, NSCoding {
	
	static var currentUser: User = User()
    var currentSpotifyUser: CurrentSpotifyUser?
	
	private(set) var caption = ""
	private(set) var createdAt = ""
	private(set) var email = "temp@example.com"
	private(set) var fbid = ""
	var isFollowing = false
	var followers: [String] = []
	var followersCount = 0
	var followingCount = 0
	var hipsterScore = 0
	var id = ""
	var likeCount = 0
	var locationID = ""
	var firstName = ""
	var lastName = ""
	var name: String {
		set(newName) {
			let fullName = newName.characters.split { $0 == " " }.map { String($0) }
			firstName = fullName.first ?? ""
			lastName = fullName.count > 1 ? fullName.last! : ""
		}
		get {
			return "\(firstName) \(lastName)"
		}
	}
	var updatedAt: String!
	var username: String = "temp_username"
	private var profileImage: UIImage?
	var imageURL: NSURL {
		return NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=large")!
	}
	
	override init() {} 
	
	init(json: JSON) {
		super.init()
		caption = json["caption"].stringValue
		createdAt = json["created_at"].stringValue
		email = json["email"].stringValue
		fbid = json["fbid"].stringValue
		isFollowing = json["is_following"].boolValue
		followers = json["followers"].arrayObject as? [String] ?? []
		followersCount = json["followers_count"].intValue
		followingCount = json["followings_count"].intValue
		hipsterScore = json["hipster_score"].intValue
		id = json["id"].stringValue
		likeCount = json["like_count"].intValue
		locationID = json["location_id"].stringValue
		name = json["name"].stringValue
		updatedAt = json["updated_at"].stringValue
		username = json["username"].stringValue
		currentSpotifyUser = User.currentUser.currentSpotifyUser
	}
	
	override var description: String {
		return "Name: \(name)| Email: \(email)| ID: \(id)| Username: \(username)| FacebookID: \(fbid)"
	}
	
	// Extend NSCoding
	// MARK: - NSCoding
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
		caption = aDecoder.decodeObjectForKey("caption") as! String
		createdAt = aDecoder.decodeObjectForKey("created_at") as! String
		email = aDecoder.decodeObjectForKey("email") as! String
		fbid = aDecoder.decodeObjectForKey("fbid") as! String
		followers = aDecoder.decodeObjectForKey("followers") as! [String]
		followersCount = aDecoder.decodeIntegerForKey("followers_count")
		hipsterScore = aDecoder.decodeIntegerForKey("hipster_score")
		id = aDecoder.decodeObjectForKey("id") as! String
		likeCount = aDecoder.decodeIntegerForKey("like_count")
		locationID = aDecoder.decodeObjectForKey("location_id") as! String
		name = aDecoder.decodeObjectForKey("name") as! String
		updatedAt = aDecoder.decodeObjectForKey("updated_at") as! String
		username = aDecoder.decodeObjectForKey("username") as! String
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(caption, forKey: "caption")
		aCoder.encodeObject(createdAt, forKey: "created_at")
		aCoder.encodeObject(email, forKey: "email")
		aCoder.encodeObject(fbid, forKey: "fbid")
		aCoder.encodeObject(followers, forKey: "followers")
		aCoder.encodeInteger(followersCount, forKey: "followers_count")
		aCoder.encodeInteger(hipsterScore, forKey: "hipster_score")
		aCoder.encodeObject(id, forKey: "id")
		aCoder.encodeInteger(likeCount, forKey: "like_count")
		aCoder.encodeObject(locationID, forKey: "location_id")
		aCoder.encodeObject(name, forKey: "name")
		aCoder.encodeObject(updatedAt, forKey: "updated_at")
		aCoder.encodeObject(username, forKey: "username")
	}
}

class CurrentSpotifyUser: NSObject, NSCoding {

    let name: String
    let username: String
    var imageURLString: String = ""
    var spotifyUserURLString: String = ""
    var spotifyUserURL: NSURL {
        return NSURL(string: spotifyUserURLString)!
    }
	var imageURL: NSURL {
        return NSURL(string: imageURLString)!
    }
	var savedTracks = [String : AnyObject]()
    
    init(json: JSON) {
        name = json["display_name"].stringValue
        username = json["id"].stringValue
        let images = json["images"].arrayValue
		imageURLString = images.isEmpty ? "" : images[0]["url"].stringValue
        let externalURLs = json["external_urls"].dictionaryValue
		spotifyUserURLString = externalURLs["spotify"]!.stringValue ?? ""
		super.init()
    }
	
    override var description: String {
        return "Name: \(name)| Username: \(username)"
    }
    
    // Extend NSCoding
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
		username = aDecoder.decodeObjectForKey("username") as! String
		super.init()
    }
	
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(username, forKey: "username")
    }
}
