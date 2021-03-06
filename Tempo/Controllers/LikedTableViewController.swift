//
//  LikedTableViewController.swift
//  Tempo
//
//  Created by Alexander Zielenski on 5/3/15.
//  Copyright (c) 2015 Alexander Zielenski. All rights reserved.
//

import UIKit

class LikedTableViewController: PlayerTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Liked"
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		playingPostType = .liked
		
		tableView.rowHeight = 91
		tableView.backgroundColor = .readCellColor
		tableView.showsVerticalScrollIndicator = false
		tableView.register(LikedTableViewCell.self, forCellReuseIdentifier: "LikedCell")

		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = .tempoRed
		tableView.tableHeaderView = searchController.searchBar
		tableView.addSubview(topView)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.tableHeaderView = notConnected(true) ? nil : searchController.searchBar
	}
	
    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		retrieveLikedSongs()
    }
	
    // MARK: - Table View Methods
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LikedCell", for: indexPath) as! LikedTableViewCell
		let posts = searchController.isActive ? filteredPosts : self.posts
		cell.likedPostView?.albumArtworkImageView?.image = nil
		cell.setupCell(spotifyAvailable: SpotifyController.sharedController.isSpotifyAvailable)
		cell.likedPostView?.post = posts[indexPath.row]
		cell.likedPostView?.postViewDelegate = self
		cell.likedPostView?.playerDelegate = self
		cell.likedPostView?.updatePlayingStatus()

		transplantPlayerAndPostViewIfNeeded(cell: cell)
		
		return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
		currentlyPlayingIndexPath = indexPath
	}
	
    func retrieveLikedSongs() {
		let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
		activityIndicatorView.center = view.center
		activityIndicatorView.startAnimating()
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			view.addSubview(activityIndicatorView)
		}
		
        API.sharedAPI.fetchLikes(User.currentUser.id) {
            self.posts = $0.map { Post(song: $0, user: User.currentUser) }
			self.preparePosts()
			
            self.tableView.reloadData()
			
			self.tableView.backgroundView = (self.posts.count == 0) ? UIView.viewForEmptyViewController(.Liked, size: self.view.bounds.size, isCurrentUser: true, userFirstName: "") : nil
			
			activityIndicatorView.stopAnimating()
			activityIndicatorView.removeFromSuperview()
			self.updatePlayingCells()
        }
    }
	
	func didToggleAdd() {
		// if there is a currentlyPlayingIndexPath, need to sync add status of playerCells and post
		if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
			if let cell = tableView.cellForRow(at: currentlyPlayingIndexPath) as? LikedTableViewCell {
				cell.likedPostView?.updateAddStatus()
				playerCenter.updateAddButton()
			}
		}
	}
}
