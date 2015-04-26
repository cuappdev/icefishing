//
//  ViewController.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/8/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SearchTrackResultsViewControllerDelegate {

    let options: UISegmentedControl = UISegmentedControl(items: ["Songs", "Users"])
    
    var childVC1 = FeedViewController(nibName: "FeedViewController", bundle: nil)
    //var childVC2 = TrendingViewController()
    var searchController: UISearchController!
    var searchNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(self.navigationController?.navigationBar.frame.height)
        // Add Songs/Users option element to the navbar
        options.selectedSegmentIndex = 0
        options.tintColor = UIColor.grayColor()
        options.addTarget(self, action: "switchTable", forControlEvents: .ValueChanged)
//        navigationItem.titleView = options
        
        navigationItem.title = "Songs"
        
        // Add plus sign to the right side of the navbar
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "initializePostCreation")
        navigationItem.rightBarButtonItem = button
        
        addChildViewController(childVC1)
        childVC1.view.frame = view.bounds
        view.addSubview(childVC1.view)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 181.0 / 255.0, green: 87.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
//        navigationController?.navigationBar.translucent = true
        
        // Add profile button to the left side of the navbar
        var profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height * 0.65))
        profileButton.setImage(UIImage(named: "white-hamburger-menu-Icon"), forState: .Normal)
//        profileButton.addTarget(self, action: "pushToProfile", forControlEvents: .TouchUpInside)
        profileButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: .TouchUpInside)
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        // Arbitrary additions for SWRevealVC
        revealViewController().panGestureRecognizer()
        revealViewController().tapGestureRecognizer()
        
    }
    
    // Add profile button
//    func pushToProfile() {
//        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
//        var feedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: navigationController!.navigationBar.frame.height * 0.65))
//        feedButton.setImage(UIImage(named: "white-hamburger-menu-Icon"), forState: .Normal)
//        feedButton.addTarget(self, action: "closeProfileView", forControlEvents: .TouchUpInside)
//        loginViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: feedButton)
//
//        searchNavigationController = UINavigationController(rootViewController: loginViewController)
//        presentViewController(searchNavigationController, animated: false, completion: nil)
//    }
    
    func initializePostCreation() {
        var searchResultsViewController = SearchTrackResultsViewController() as SearchTrackResultsViewController
        
        let searchViewController = SearchTrackViewController()
        searchNavigationController = UINavigationController(rootViewController: searchViewController)

        searchController = UISearchController(searchResultsController: searchResultsViewController)
        searchController.searchResultsUpdater = searchResultsViewController
        searchController.hidesNavigationBarDuringPresentation = false

        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.placeholder = NSLocalizedString("Search to post a song of the Day", comment: "")
        searchController.searchBar.showsCancelButton = false
        searchController.delegate = searchViewController
        
        searchResultsViewController.delegate = self

        searchViewController.navigationItem.titleView = searchController.searchBar
        searchViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "closeSearchView")

        presentViewController(searchNavigationController, animated: false, completion: nil)
        delay(0.05) {
            self.searchController.searchBar.becomeFirstResponder()
            return
        }
    }
    
    func postSong(track: TrackResult) {
        closeSearchView()
        childVC1.addSong(track)
        
        println("TODO: add this track")
        println(track)
    }
    
    func closeProfileView() {
        searchNavigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func closeSearchView() {
        searchNavigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}