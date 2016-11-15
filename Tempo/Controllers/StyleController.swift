//
//  StyleController.swift
//  Tempo
//
//  Created by Lucas Derraugh on 8/8/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class StyleController {
	class func applyStyles() {
		// UIKit appearances
		UINavigationBar.appearance().barTintColor = UIColor.tempoLightRed
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().barStyle = .black
		UINavigationBar.appearance().isTranslucent = false
		UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 17.0)!, NSForegroundColorAttributeName: UIColor.white]
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		
		UISearchBar.appearance().backgroundImage = UIImage()
		UISearchBar.appearance().backgroundColor = UIColor.tempoLightRed
		UISearchBar.appearance().barTintColor = UIColor.tempoLightRed
		UISearchBar.appearance().tintColor = UIColor.white
		UISearchBar.appearance().isTranslucent = true
		UISearchBar.appearance().placeholder = "Search"
		UISearchBar.appearance().searchBarStyle = UISearchBarStyle.prominent
		
		if #available(iOS 9.0, *) {
			UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.tempoDarkRed
			UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Book", size: 14.0)!], for: UIControlState())
		}
		
		UITableView.appearance().backgroundColor = UIColor.tempoDarkGray
		UITableView.appearance().separatorColor = UIColor.clear
		UITableView.appearance().separatorStyle = .none
		UITableView.appearance().sectionHeaderHeight = 0
		UITableView.appearance().sectionFooterHeight = 0
		UITableView.appearance().rowHeight = 96
		
		UITableViewCell.appearance().backgroundColor = UIColor.tempoDarkGray
		
		// User defined appearances
		PostButton.appearance().backgroundColor = UIColor.tempoLightRed
		SearchPostView.appearance().backgroundColor = UIColor.tempoLightGray
	}
}
