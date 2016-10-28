//
//  ExpandedPlayerView.swift
//  Tempo
//
//  Created by Logan Allen on 10/26/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MarqueeLabel

let ExpandedPostLikedStatusChangeNotification = "PostLikedStatusChange"

protocol ExpandedPostDelegate {
	var post: Post? { get }
}

class ExpandedPlayerView: UIView, ExpandedPostDelegate {
	
	private let height = CGFloat(204)
	
	@IBOutlet weak var postDetailLabel: UILabel!
	@IBOutlet weak var songLabel: MarqueeLabel!
	@IBOutlet weak var artistLabel: MarqueeLabel!
	@IBOutlet weak var albumImage: UIImageView!
	@IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var progressView: ProgressView!
	@IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeButtonImage: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collapseButton: UIButton!
	
    @IBOutlet weak var addButtonImage: UIImageView!
	var postsRef: [Post]?
	var postRefIndex: Int?
	var postsLikable = false
	var postHasInfo = false
	var parentNav: PlayerNavigationController?
	
	var post: Post? {
		didSet {
			if let newPost = post {
				
				updatePostInfo(newPost)
				updateAddButton()
				updateLikeButton()
				updateSongStatus()
				updatePlayingStatus()
				
				songLabel.holdScrolling = false
				artistLabel.holdScrolling = false
			}
		}
	}
	
	var songStatus: SavedSongStatus = .NotSaved
	
	func setup(parent: PlayerNavigationController) {
		parentNav = parent
		let tap = UITapGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.collapseTap(_:)))
		collapseButton.addGestureRecognizer(tap)
		let pan = UIPanGestureRecognizer(target: self, action: #selector(ExpandedPlayerView.collapsePan(_:)))
		self.addGestureRecognizer(pan)
		progressView.expandedDelegate = self
		progressView.type = .ExpandedPlayer
		
		updateAddButton()
		likeButton.userInteractionEnabled = false
		
		setupMarqueeLabel(songLabel)
		setupMarqueeLabel(artistLabel)
		
		NSNotificationCenter.defaultCenter().addObserverForName(PlayerDidFinishPlayingNotification, object: nil, queue: nil) { [weak self] note in
			if let current = self?.post {
				if current.player == note.object as? Player {
					if let path = self?.postRefIndex {
						var index = path + 1
						if let postsRef = self?.postsRef {
							let count = postsRef.count
							index = index >= count ? 0 : index
							self?.post = postsRef[index]
							self?.postRefIndex = index
						} else {
							self?.updatePlayingStatus()
						}
					}
				}
			}
		}
	}
	
	private func getPostTime(time: String) -> String {
		let num: String = time.substringToIndex(time.endIndex.advancedBy(-1))
		let unit: String = time.substringFromIndex(time.endIndex.advancedBy(-1))
		let convertedUnit: String = {
			switch unit {
				case "s":
					return (Int(num) == 1) ? "second" : "seconds"
				case "m":
					return (Int(num) == 1) ? "minute" : "minutes"
				case "h":
					return (Int(num) == 1) ? "hour" : "hours"
				case "d":
					return (Int(num) == 1) ? "day" : "days"
				default:
					return (Int(num) == 1) ? "decade" : "decades"
			}
		}()
		return "\(num) \(convertedUnit)"
	}
	
	private func updatePostInfo(newPost: Post) {
		songLabel.text = newPost.song.title
		artistLabel.text = newPost.song.artist
		albumImage.hnk_setImageFromURL(newPost.song.smallArtworkURL ?? NSURL())
		if postHasInfo {
			let time = getPostTime(newPost.relativeDate())
			postDetailLabel.text = "\(newPost.user.name) posted \(time) ago"
		} else {
			postDetailLabel.text = ""
		}
	}
	
	private func updateSongStatus() {
		if let selectedPost = post {
			if (User.currentUser.currentSpotifyUser?.savedTracks[selectedPost.song.spotifyID] != nil) ?? false {
				songStatus = .Saved
			} else {
				songStatus = .NotSaved
			}
		}
	}
	
	func collapseTap(sender: UITapGestureRecognizer) {
		parentNav?.animateExpandedCell(false)
	}
	
	func collapsePan(sender: UIPanGestureRecognizer) {
		if sender.state == .Began || sender.state == .Changed {
			let translation = sender.translationInView(self)
			let maxCenter = UIScreen.mainScreen().bounds.height - height/2
			
			if translation.y > 0 || sender.view!.center.y > maxCenter {
				if sender.view!.center.y + translation.y < maxCenter {
					sender.view!.center.y = maxCenter
				} else {
					sender.view!.center.y = sender.view!.center.y + translation.y
				}
			}
			sender.setTranslation(CGPointMake(0,0), inView: self)
		}
		
		if sender.state == .Ended {
			let velocity = sender.velocityInView(self)
			parentNav?.animateExpandedCell(velocity.y < 0)
		}
	}
	
	func updatePlayingStatus() {
		if let selectedPost = post {
			let isPlaying = selectedPost.player.isPlaying
			songLabel.holdScrolling = !isPlaying
			artistLabel.holdScrolling = !isPlaying
		}
		
		updatePlayToggleButton()
	}
	
	@IBAction func playToggleButtonClicked(sender: UIButton) {
		if let selectedPost = post {
			selectedPost.player.togglePlaying()
			updatePlayToggleButton()
		}
	}
	
	private func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "pause" : "play"
			progressView.setUpTimer()
			playToggleButton.setBackgroundImage(UIImage(named: name), forState: .Normal)
		}
	}
	
	@IBAction func addButtonClicked(sender: UIButton) {
		if songStatus == .NotSaved {
			SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
				if success {
					self.addButtonImage.image = UIImage(named: "check")
					self.songStatus = .Saved
				}
			}
		} else if songStatus == .Saved {
			SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
				if success {
					self.addButtonImage.image = UIImage(named: "plus")
					self.songStatus = .NotSaved
				}
			}
		}
	}
	
	private func updateAddButton() {
		addButton!.userInteractionEnabled = false
		if let _ = post {
			SpotifyController.sharedController.spotifyIsAvailable { success in
				if success {
					self.addButton!.userInteractionEnabled = true
				}
			}
		}
	}
	
	@IBAction func likeButtonClicked(sender: UIButton) {
		if let selectedPost = post {
			selectedPost.toggleLike()
			updateLikeButton()
			NSNotificationCenter.defaultCenter().postNotificationName(PostLikedStatusChangeNotification, object: self)
		}
	}
	
	func updateLikeButton() {
		if let selectedPost = post {
			if postsLikable {
				likeButton.userInteractionEnabled = true
				let name = selectedPost.isLiked ? "filled-heart" : "empty-heart"
				likeButtonImage.image = UIImage(named: name)
			} else {
				likeButton.userInteractionEnabled = false
				likeButtonImage.image = UIImage(named: "empty-heart")
			}
		}
	}
	
	private func setupMarqueeLabel(label: MarqueeLabel) {
		label.speed = .Duration(8)
		label.trailingBuffer = 10
		label.type = .Continuous
		label.fadeLength = 8
		label.tapToScroll = false
		label.holdScrolling = true
		label.animationDelay = 0
	}
	
}
