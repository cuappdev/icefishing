//
//  ProgressView.swift
//  Tempo
//
//  Created by Jesse Chen on 10/19/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

enum Type {
	case NormalPlayer
	case ExpandedPlayer
}

class ProgressView: UIView {
	
	var playerDelegate: PostDelegate!
	var expandedDelegate: ExpandedPostDelegate!
	let fillColor = UIColor.tempoLightRed
	private var updateTimer: NSTimer?
	var type: Type!
	
	override func drawRect(rect: CGRect) {
		var progress = 0.0
		if type == .NormalPlayer {
			progress = playerDelegate.post?.player.progress ?? 0
		} else {
			progress = expandedDelegate.post?.player.progress ?? 0
		}
		
		super.drawRect(rect)
		fillColor.setFill()
		CGContextFillRect(UIGraphicsGetCurrentContext(),
			CGRect(x: 0, y: 0, width: bounds.width * CGFloat(progress), height: bounds.height))
	}
	
	dynamic private func timerFired(timer: NSTimer) {
		if type == .NormalPlayer {
			if playerDelegate.post?.player.isPlaying ?? false {
				setNeedsDisplay()
			}
		} else {
			if expandedDelegate.post?.player.isPlaying ?? false {
				setNeedsDisplay()
			}
		}
	}
	
	func setUpTimer() {
		if type == .NormalPlayer {
			if updateTimer == nil && playerDelegate.post?.player.isPlaying ?? false {
				// 60 fps
				updateTimer = NSTimer(timeInterval: 1.0 / 60.0,
				                      target: self, selector: #selector(timerFired(_:)),
				                      userInfo: nil,
				                      repeats: true)
				
				NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
			} else if !(playerDelegate.post?.player.isPlaying ?? false) {
				updateTimer?.invalidate()
				updateTimer = nil
			}
		} else {
			if updateTimer == nil && expandedDelegate.post?.player.isPlaying ?? false {
				// 60 fps
				updateTimer = NSTimer(timeInterval: 1.0 / 60.0,
				                      target: self, selector: #selector(timerFired(_:)),
				                      userInfo: nil,
				                      repeats: true)
				
				NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
			} else if !(expandedDelegate.post?.player.isPlaying ?? false) {
				updateTimer?.invalidate()
				updateTimer = nil
			}
		}
		
	}
}
