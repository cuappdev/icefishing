//
//  ADRefreshControl.swift
//  JackrabbitRefreshSwift
//
//  Created by Dennis Fedorko on 5/4/15.
//  Copyright (c) 2015 Jackrabbit Mobile. All rights reserved.
//

import UIKit

class ADRefreshControl {
	
	var refreshControl: UIRefreshControl!
	var vinylView: UIImageView!
	var isRefreshAnimating = false
	var timesAnimationLooped = 0
	var pullDistance: CGFloat = 0
	
	init(refreshControl: UIRefreshControl) {
		
		self.refreshControl = refreshControl
		
		// Create the graphic image views
		vinylView = UIImageView(image: UIImage(named: "vinyl-red")?.imageWithRenderingMode(.AlwaysTemplate))
		vinylView.tintColor = UIColor.tempoLightRed
		vinylView.frame = CGRectMake(0, 0, 45, 45)
		vinylView.layer.opacity = 0
		
		// Add the graphics to the loading view
		refreshControl.addSubview(vinylView)
		
		// Hide the original spinner icon
		refreshControl.tintColor = UIColor.clearColor()
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		
		// Get the current size of the refresh controller
		var refreshBounds = refreshControl.bounds
		
		// Distance the table has been pulled >= 0
		let newPullDistance = max(0, -refreshControl.frame.origin.y)
		
		if !isRefreshAnimating {
			let direction = newPullDistance < pullDistance ? -10.0 : 10.0
			vinylView.transform = CGAffineTransformRotate(vinylView.transform, CGFloat(direction * M_PI/180))
		}
		
		pullDistance = newPullDistance
		
		// Animate vinyl opacity when initially appearing/fading
		vinylView.layer.opacity = isRefreshAnimating ? 1.0 : Float(pullDistance-10.0)/45.0
		
		//have vinyl case follow disc up to a certain point then return
		vinylView.center = CGPointMake(refreshBounds.size.width/2.0, pullDistance/2.0)
		
		// Set the encompassing view's frames
		refreshBounds.size.height = pullDistance
		
		// If we're refreshing and the animation is not playing, then play the animation
		if refreshControl!.refreshing && !isRefreshAnimating {
			animateRefreshView()
		}
	}
	
	func animateRefreshView() {
		
		// Flag that we are animating
		isRefreshAnimating = true
		
		UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {

			// Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
			self.vinylView.transform = CGAffineTransformRotate(self.vinylView.transform, CGFloat(-1 * M_PI_2))
			if self.timesAnimationLooped % 2 == 0 {
				self.vinylView.transform = CGAffineTransformScale(self.vinylView.transform, 1.30, 1.30)
			} else {
				self.vinylView.transform = CGAffineTransformScale(self.vinylView.transform, 1/1.3, 1/1.3)
			}
		}, completion: { finished in
			// If still refreshing, keep spinning, else reset
			if self.refreshControl.refreshing {
				self.animateRefreshView()
			} else {
				self.resetAnimation()
			}
		})
		timesAnimationLooped += 1
	}
	
	func resetAnimation() {
		
		// Reset our flags and background color
		if timesAnimationLooped % 2 != 0 {
			vinylView.transform = CGAffineTransformScale(vinylView.transform, 1/1.3, 1/1.3)
		}
		timesAnimationLooped = 0
		isRefreshAnimating = false
	}
	
}