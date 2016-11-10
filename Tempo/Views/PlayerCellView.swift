//
//  PlayerCellView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MarqueeLabel

class PlayerCellView: UIView {
	
	@IBOutlet weak var songLabel: MarqueeLabel!
	@IBOutlet weak var artistLabel: MarqueeLabel!
    @IBOutlet weak var playToggleButton: UIButton!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
	
	var postsLikable = false
	var parentNav: PlayerNavigationController?
	
	var songStatus: SavedSongStatus = .NotSaved
	var post: Post?
	
	func setup(parent: PlayerNavigationController) {
		parentNav = parent
		backgroundColor = UIColor.tempoSuperDarkGray
		let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerCellView.expandTap(_:)))
		self.addGestureRecognizer(tap)
		progressView.playerDelegate = parentNav
		progressView.backgroundColor = UIColor.tempoSuperDarkRed
		
		updateAddButton()
		likeButton.userInteractionEnabled = false
		playToggleButton.layer.cornerRadius = 5
		playToggleButton.clipsToBounds = true
		
		setupMarqueeLabel(songLabel)
		setupMarqueeLabel(artistLabel)
	}
	
	func updateCellInfo(newPost: Post) {
		post = newPost
		songLabel.text = newPost.song.title
		artistLabel.text = newPost.song.artist
		songLabel.holdScrolling = false
		artistLabel.holdScrolling = false
		self.userInteractionEnabled = true
		
		updateAddButton()
		updateLikeButton()
		updateSongStatus()
		updatePlayingStatus()
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
	
	func expandTap(sender: UITapGestureRecognizer) {
		parentNav?.animateExpandedCell(true)
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
	
	func updatePlayToggleButton() {
		if let selectedPost = post {
			let name = selectedPost.player.isPlaying ? "pause-red" : "play-red"
			progressView.setUpTimer()
			playToggleButton.setBackgroundImage(UIImage(named: name), forState: .Normal)
		}
	}
    
	@IBAction func addButtonClicked(sender: UIButton) {
		if songStatus == .NotSaved {
			SpotifyController.sharedController.saveSpotifyTrack(post!) { success in
				if success {
					self.addButton.setBackgroundImage(UIImage(named: "check"), forState: .Normal)
					self.songStatus = .Saved
				}
			}
		} else if songStatus == .Saved {
			SpotifyController.sharedController.removeSavedSpotifyTrack(post!) { success in
				if success {
					self.addButton.setBackgroundImage(UIImage(named: "plus"), forState: .Normal)
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
				likeButton?.setBackgroundImage(UIImage(named: name), forState: .Normal)
			} else {
				likeButton.userInteractionEnabled = false
				likeButton?.setBackgroundImage(UIImage(named: "empty-heart"), forState: .Normal)
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