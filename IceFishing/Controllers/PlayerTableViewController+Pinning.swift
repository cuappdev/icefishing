//
//  PlayerTableViewController+Pinning.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 2/24/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

extension PlayerTableViewController {
	
	internal func setupPinViews() {
		//pinViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerTableViewController.togglePlay))
		pinView.backgroundColor = UIColor.iceLightGray
		pinView.postView.playerController = self as PlayerTableViewController
	}
	
	internal func positionPinViews() {
		let frame = tableView.frame
		let myFrame = view.frame
		
		topPinViewContainer.frame = CGRectMake(0, frame.minY + tableView.contentInset.top, myFrame.width, tableView.rowHeight)
		bottomPinViewContainer.frame = CGRectMake(0, frame.maxY - tableView.rowHeight, myFrame.width, tableView.rowHeight)
		
		view.superview!.addSubview(topPinViewContainer)
		view.superview!.addSubview(bottomPinViewContainer)
		
		topPinViewContainer.hidden = true
		bottomPinViewContainer.hidden = true
		
		pinView.frame = CGRectMake(0, 0, view.frame.width, tableView.rowHeight)
	}
	
	func pinIfNeeded() {
		guard let selected = currentlyPlayingIndexPath else { return }
		pinnedIndexPath = currentlyPlayingIndexPath
		if pinView.postView.post != posts[selected.row] {
//			let cell = tableView.cellForRowAtIndexPath(selected) as! FeedTableViewCell
//			pinView.postView = cell.postView
			pinView.postView.post = posts[selected.row]
		}
		guard let selectedCell = tableView.cellForRowAtIndexPath(selected) else { return }
		if selectedCell.frame.minY < tableView.contentOffset.y {
			topPinViewContainer.addSubview(pinView)
			topPinViewContainer.hidden = false
		} else if selectedCell.frame.maxY > tableView.contentOffset.y + tableView.frame.height {
			pinView.postView.post = posts[selected.row]
			bottomPinViewContainer.addSubview(pinView)
			bottomPinViewContainer.hidden = false
		} else {
			topPinViewContainer.hidden = true
			bottomPinViewContainer.hidden = true
		}
	}
	
	func updatePlayInfo() {
		currentlyPlayingIndexPath = pinnedIndexPath
		currentlyPlayingPost = pinView.postView.post
	}
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		pinIfNeeded()
	}
}
