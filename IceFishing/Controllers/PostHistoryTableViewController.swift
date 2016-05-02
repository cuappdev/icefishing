//
//  PostHistoryTableViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import MediaPlayer

class PostHistoryTableViewController: PlayerTableViewController, PostViewDelegate {
	
	var songLikes: [Int] = []
    var postedDates: [NSDate] = []
    var index: Int?
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
		notifCenterSetup()
		commandCenterHandler()
		
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.iceDarkGray
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        navigationItem.title = "Post History"
		
		extendedLayoutIncludesOpaqueBars = true
		definesPresentationContext = true

		pinView.postView.type = .History
    }
    
    override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if index != nil {
			let selectedRow = NSIndexPath(forRow: index!, inSection: 0)
			tableView.scrollToRowAtIndexPath(selectedRow, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
		}
		
		notConnected()
    }
	
    // TableView Methods
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
		
		cell.postView.type = .History
		let posts = searchController.active ? filteredPosts : self.posts
		cell.postView.post = posts[indexPath.row]
		cell.postView.delegate = self
		cell.postView.playerController = self as PlayerTableViewController
		cell.postView.post?.player.prepareToPlay()
		
        let date = NSDateFormatter.simpleDateFormatter.stringFromDate(postedDates[indexPath.row])
		cell.postView.dateLabel!.text = "\(date)"
		
		return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! FeedTableViewCell
        selectedCell.postView.backgroundColor = UIColor.iceLightGray
		currentlyPlayingIndexPath = indexPath
    }

}