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
		view.backgroundColor = UIColor.tempoDarkGray
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true
		
		tableView.rowHeight = 100
		tableView.showsVerticalScrollIndicator = false
		tableView.register(LikedTableViewCell.self, forCellReuseIdentifier: "LikedCell")
		
		addHamburgerMenu()

		// Fix color above search bar
		let topView = UIView(frame: view.frame)
		topView.frame.origin.y = -view.frame.size.height
		topView.backgroundColor = UIColor.tempoLightRed
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
		cell.setupCell()
		cell.postView?.post = posts[indexPath.row]
		cell.postView?.postViewDelegate = self
		cell.postView?.playerDelegate = self
		cell.postView?.updatePlayingStatus()
		
		return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
		playerNav.playerCell.postsLikable = false
		playerNav.expandedCell.postsLikable = false
		playerNav.expandedCell.postHasInfo = false
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
			self.posts.sort { $0.song.description < $1.song.description }
			self.preparePosts()
			
            self.tableView.reloadData()
			
			if self.posts.count == 0 {
				self.tableView.backgroundView = UIView.viewForEmptyViewController(.Liked, size: self.view.bounds.size, isCurrentUser: true, userFirstName: "")
			} else {
				self.tableView.backgroundView = nil
			}
			
			activityIndicatorView.stopAnimating()
			activityIndicatorView.removeFromSuperview()
        }
    }

}
