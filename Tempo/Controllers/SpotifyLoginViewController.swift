//
//  SpotifyLoginViewController.swift
//  Tempo
//
//  Created by Keivan Shahida on 11/11/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import UIKit

class SpotifyLoginViewController: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		connectButton.layer.cornerRadius = 5
	}
		
    @IBAction func connectToSpotify(sender: UIButton) {
		SpotifyController.sharedController.loginToSpotify { (success) in
			if success { if let session = SPTAuth.defaultInstance().session { if session.isValid() {
				SpotifyController.sharedController.setSpotifyUser(session.accessToken)
						//change view
						let appDelegate = UIApplication.shared.delegate as! AppDelegate
						appDelegate.toggleRootVC()
					}
				}
			}
		}
    }

    @IBAction func skipSpotify(sender: UIButton) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.toggleRootVC()
    }
}
