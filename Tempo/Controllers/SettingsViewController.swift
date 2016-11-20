//
//  SettingsViewController.swift
//  Tempo
//
//  Created by Keivan Shahida on 11/20/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
	
	@IBOutlet weak var profilePicture: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var loginToSpotifyButton: UIButton!
	@IBOutlet weak var goToSpotifyButton: UIButton!
	@IBOutlet weak var logOutSpotifyButton: UIButton!
	@IBOutlet weak var toggleNotifications: UISwitch!
	@IBOutlet weak var useLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateSpotifyState()
		profilePicture.hnk_setImageFromURL(User.currentUser.imageURL)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		title = "Settings"
		addHamburgerMenu()
	}
	
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {
		if let session = SPTAuth.defaultInstance().session {
			if session.isValid() {
				SpotifyController.sharedController.setSpotifyUser(session.accessToken)
				let currentSpotifyUser = User.currentUser.currentSpotifyUser
				self.nameLabel.text = "\(User.currentUser.firstName) \(User.currentUser.lastName)"
				self.usernameLabel.text = "@\(currentSpotifyUser!.username)"
			}
			loggedInToSpotify(session.isValid())
		} else {
			loggedInToSpotify(false)
		}
	}
	
	func loggedInToSpotify(_ loggedIn: Bool) {
		loginToSpotifyButton.isHidden = loggedIn
		useLabel.isHidden = loggedIn
		
		profilePicture.isHidden = !loggedIn
		nameLabel.isHidden = !loggedIn
		usernameLabel.isHidden = !loggedIn
		goToSpotifyButton.isHidden = !loggedIn
		logOutSpotifyButton.isHidden = !loggedIn
	}
	
	@IBAction func loginToSpotify() {
		SpotifyController.sharedController.loginToSpotify { (success) in
			if success {
				self.updateSpotifyState()
			}
		}
	}
	
	@IBAction func toggledNotifications(_ sender: AnyObject) {
		//turn on or off notifications
		
	}
	
	@IBAction func goToSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.openSpotifyURL()
	}
	
	@IBAction func logOutSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.closeCurrentSpotifySession()
		
		updateSpotifyState()
	}
}
