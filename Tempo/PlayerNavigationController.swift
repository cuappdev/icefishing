//
//  PlayerNavigationController.swift
//  Tempo
//
//  Created by Jesse Chen on 10/23/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class PlayerNavigationController: UINavigationController {

	var playerCell: PlayerCellView!
	let frameHeight = CGFloat(72)
	
	var expandedCell: ExpandedPlayerView!
	let expandedHeight = CGFloat(204)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let playerFrame = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - frameHeight, UIScreen.mainScreen().bounds.width, frameHeight))
		playerFrame.backgroundColor = UIColor.redColor()
		self.view.addSubview(playerFrame)
		playerCell = NSBundle.mainBundle().loadNibNamed("PlayerCellView", owner: self, options: nil).first as! PlayerCellView
		playerCell.setup(self)
		playerCell.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, frameHeight)
		playerFrame.addSubview(playerCell)
		// Do any additional setup after loading the view.
		
		// Setup expandedCell
		expandedCell = NSBundle.mainBundle().loadNibNamed("ExpandedPlayerView", owner: self, options: nil).first as! ExpandedPlayerView
		expandedCell.setup(self)
		expandedCell.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, expandedHeight)
		self.view.addSubview(expandedCell)
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func animateExpandedCell(isExpanding: Bool) {
		UIView.animateWithDuration(0.2) {
			let loc = isExpanding ? self.expandedHeight : CGFloat(0)
			UIView.animateWithDuration(0.2, animations: {
				self.expandedCell.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - loc, UIScreen.mainScreen().bounds.width, self.expandedHeight)
				self.expandedCell.layer.opacity = isExpanding ? 1 : 0
			})
		}
	}
}