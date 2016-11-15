//
//  API.swift
//  Tempo
//
//  Created by Lucas Derraugh on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKShareKit

private enum Router: URLConvertible {
	static let baseURLString = "https://icefishing-web.herokuapp.com"
	case root
	case validAuthenticate
	case validUsername
	case sessions
	case userSearch
	case users(String)
	case followers(String)
	case following(String)
	case feed(String)
	case feedEveryone
	case history(String)
	case likes(String?)
	case followings
	case posts
	case followSuggestions
    case spotifyAccessToken
	
	func asURL() throws -> URL {
		if let url = URL(string: URLString) {
			return url
		}
		
		throw AFError.invalidURL(url: self)
	}
	
	var URLString: String {
		let path: String = {
			switch self {
			case .root:
				return "/"
			case .validAuthenticate:
				return "/users/authenticate"
			case .validUsername:
				return "/users/valid_username"
			case .sessions:
				return "/sessions"
			case .userSearch:
				return "/users.json"
			case .users(let userID):
				return "/users/\(userID)"
			case .followers(let userID):
				return "/users/\(userID)/followers"
			case .following(let userID):
				return "/users/\(userID)/following"
			case .feed(let userID):
				return "/\(userID)/feed"
			case .feedEveryone:
				return "/feed.json"
			case .history(let userID):
				return "/users/\(userID)/posts"
			case .likes(let userID):
				if userID != nil {
					return "/users/\(userID!)/likes"
				}
				return "/likes"
			case .followings:
				return "/followings"
			case .posts:
				return "/posts"
			case .followSuggestions:
				return "/users/suggestions"
            case .spotifyAccessToken:
                return "/spotify/get_access_token"
			}
			}()
		return Router.baseURLString + path
	}
}

private let sessionCodeKey = "SessionCodeKey"

class API {
	
	static let sharedAPI = API()
	var isAPIConnected = true
	var isConnected = true

	// Mappings
	fileprivate let postMapping: ([String: [AnyObject]]) -> [Post]? = {
		$0["posts"]?.map { Post(json: JSON($0)) }
	}
	
	fileprivate var sessionCode: String {
		set {
			UserDefaults.standard.set(newValue, forKey: sessionCodeKey)
		}
		get {
			return UserDefaults.standard.object(forKey: sessionCodeKey) as? String ?? ""
		}
	}
	
	func usernameIsValid(_ username: String, completion: @escaping (Bool) -> Void) {
		let map: ([String: Bool]) -> Bool? = { $0["is_valid"] }
		post(.validUsername, params: ["username": username as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fbAuthenticate(_ fbid: String, userToken: String, completion: @escaping (_ success: Bool, _ newUser: Bool) -> Void) {
		let map: ([String: AnyObject]) -> (success: Bool, newUser: Bool) = {
			if let user = $0["user"] as? [String: AnyObject], let code = $0["session"]?["code"] as? String {
				if let success = $0["success"] as? Bool, success == true {
					guard let newUser = $0["new_user"] as? Bool else { return (false, false) }
					self.sessionCode = code
					User.currentUser = User(json: JSON(user))
					return (success, newUser)
				}
			}
			
			return (false, false)
		}
		
		let userRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, id, email, picture.type(large)"])
		
		let _ = userRequest?.start { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
			if error != nil { return }
			
			guard let userJSON = result as? [String:Any] else {
				return
			}
			
			let email = userJSON["email"] as? String ?? ""
			let name = userJSON["email"] as? String ?? ""
			let fbid = userJSON["email"] as? String ?? ""
			
			let user: [String:AnyObject] = [
				"email": email as AnyObject,
				"name": name as AnyObject,
				"fbid": fbid as AnyObject,
				"usertoken": userToken as AnyObject
			]
			
			self.post(.validAuthenticate, params: ["user": user as AnyObject], map: map, completion: completion)
		}
	}
	
	func registerForRemotePushNotificationsWithDeviceToken(_ deviceToken: Data) {
		var token = NSString(format: "%@", deviceToken as NSData)
		token = token.replacingOccurrences(of: "<", with: "") as NSString
		token = token.replacingOccurrences(of: ">", with: "") as NSString
		token = token.replacingOccurrences(of: " ", with: "") as NSString
		
		let baseURL = "ec2-35-162-151-106.us-west-2.compute.amazonaws.com/register_user"
		
		/// Test user_id for now, should be actual user id
		/// This api call should only be made in settings and after login flow
		/// so the user id will be set
		let params = ["app": "TEMPO", "push_id":"\(token)", "user_id": "3"]
		let headers = ["Content-Type" : "application/json"]
		
		Alamofire.request(baseURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
			debugPrint(response)
		}
	}
	
	func setCurrentUser(_ fbid: String, fbAccessToken: String, completion: @escaping (Bool) -> Void) {
		let user = ["fbid": fbid, "usertoken": fbAccessToken]
		let map: ([String: AnyObject]) -> Bool = {
			guard let user = $0["user"] as? [String: AnyObject], let code = $0["session"]?["code"] as? String else { return false }
			self.sessionCode = code
			User.currentUser = User(json: JSON(user))
			return true
		}
		self.post(.sessions, params: ["user": user as AnyObject], map: map, completion: completion)
	}
	
	func updateCurrentUser(_ changedUsername: String, didSucceed: @escaping (Bool) -> Void) {
		let map: ([String: Bool]) -> Bool? = {
			guard let success = $0["success"], success != false else { return false }
			User.currentUser.username = changedUsername
			return true
		}
		let changes = ["username": changedUsername]
		patch(.users(User.currentUser.id), params: ["user": changes as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: didSucceed)
	}
	
	func searchUsers(_ username: String, completion: @escaping ([User]) -> Void) {
		let map: ([String: [AnyObject]]) -> [User]? = {
			$0["users"]?.map { User(json: JSON($0)) }
		}
		get(.userSearch, params: ["q": username as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchUser(_ userID: String, completion: @escaping (User) -> Void) {
		let map: ([String: AnyObject]) -> User? = { User(json: JSON($0)) }
		get(.users(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFollowers(_ userID: String, completion: @escaping ([User]) -> Void) {
		let map: ([String: AnyObject]) -> [User]? = {
			guard let followers = $0["followers"] as? [[String: AnyObject]] else { return nil }
			return followers.map { User(json: JSON($0)) }
		}
		get(.followers(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFollowing(_ userID: String, completion: @escaping ([User]) -> Void) {
		let map: ([String: AnyObject]) -> [User]? = {
			guard let following = $0["following"] as? [[String: AnyObject]] else { return nil }
			return following.map { User(json: JSON($0)) }
		}
		get(.following(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFollowSuggestions(_ completion: @escaping ([User]) -> Void, length: Int, page: Int) {
		let map: ([String: AnyObject]) -> [User]? = {
			guard let users = $0["users"] as? [AnyObject] else { return [] }
			return users.map { User(json: JSON($0)) }
		}
		post(.followSuggestions, params: ["p": page as AnyObject, "l": length as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func fetchFeed(_ userID: String, completion: @escaping ([Post]) -> Void) {
		get(.feed(userID), params: ["session_code": sessionCode as AnyObject], map: postMapping, completion: completion)
	}
	
	// Method used for testing purposes
	func fetchFeedOfEveryone(_ completion: @escaping ([Post]) -> Void) {
		get(.feedEveryone, params: ["session_code": sessionCode as AnyObject], map: postMapping, completion: completion)
	}
	
	func fetchPosts(_ userID: String, completion: @escaping ([Post]) -> Void) {
		get(.history(userID), params: ["id": userID as AnyObject, "session_code": sessionCode as AnyObject], map: postMapping, completion: completion)
	}
	
	func updateLikes(_ postID: String, unlike: Bool, completion: (([String: Bool]) -> Void)? = nil) {
		post(.likes(nil), params: ["post_id": postID as AnyObject, "unlike": unlike as AnyObject, "session_code": sessionCode as AnyObject], map: { $0 }, completion: completion)
	}
	
	func fetchLikes(_ userID: String, completion: @escaping ([Song]) -> Void) {
		let map: ([String: [AnyObject]]) -> [Song]? = {
			let songIDs: [String] = $0["songs"]?.flatMap { $0["spotify_url"] as? String } ?? []
			return songIDs.map { Song(songID: $0) }
		}
		get(.likes(userID), params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
	
	func updateFollowings(_ userID: String, unfollow: Bool, completion: (([String: Bool]) -> Void)? = nil) {
		post(.followings, params: ["followed_id": userID as AnyObject, "unfollow": unfollow as AnyObject, "session_code": sessionCode as AnyObject], map: { $0 as [String: Bool] }, completion: completion)
	}
	
	func updatePost(_ userID: String, song: Song, completion: @escaping ([String: AnyObject]) -> Void) {
		let songDict = [
			"artist": song.artist,
			"track": song.title,
			"spotify_url": song.spotifyID
		]
		let map: ([String: AnyObject]) -> [String: AnyObject]? = { $0 }
		post(.posts, params: ["user_id": userID as AnyObject, "song": songDict as AnyObject, "session_code": sessionCode as AnyObject], map: map, completion: completion)
	}
    
    func getSpotifyAccessToken(_ completion: @escaping (Bool, String, Double) -> Void) {
        let map: ([String: AnyObject]) -> (Bool, String, Double)? = {
            let expiresAt = $0["expires_at"] as? Double ?? 0.0
            
			if let success = $0["success"] as? Bool, success == true {
                let accessToken = $0["access_token"] as? String ?? ""
                return (success, accessToken, expiresAt)
            } else {
                let url = $0["url"] as? String ?? ""
                return (false, url, expiresAt)
            }
        }
        get(.spotifyAccessToken, params: ["session_code": sessionCode as AnyObject], map: map, completion: completion)
    }
	
	// MARK: - Private Methods
	
	fileprivate func post<O, T>(_ router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		makeNetworkRequest(.post, router: router, params: params, map: map, completion: completion)
	}
	
	fileprivate func get<O, T>(_ router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		makeNetworkRequest(.get, router: router, params: params, map: map, completion: completion)
	}
	
	fileprivate func patch<O, T>(_ router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		makeNetworkRequest(.patch, router: router, params: params, map: map, completion: completion)
	}
	
	fileprivate func makeNetworkRequest<O, T>(_ method: Alamofire.HTTPMethod, router: Router, params: [String: AnyObject], map: @escaping (O) -> T?, completion: ((T) -> Void)?) {
		
		
		Alamofire.request(router, method: method, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in

			if let json = response.result.value as? O {
					if let obj = map(json) {
						completion?(obj)
						self.isConnected = true
						self.isAPIConnected = true
					} else {
						print(json)
					}
				} else if let error = response.result.error {
					print(error)
//					TODO
//					if error.code != -1009 {
//						self.isAPIConnected = false
//						self.isConnected = true
//						
//					} else {
//						self.isAPIConnected = true
//						self.isConnected = false
//					}
				}
		})
	}
}
