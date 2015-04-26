//
//  ViewController.swift
//  IceFishingTrending
//
//  Created by Joseph Antonakakis on 3/8/15.
//  Copyright (c) 2015 Joseph Antonakakis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SearchTrackResultsViewControllerDelegate, UISearchControllerDelegate {

    let options: UISegmentedControl = UISegmentedControl(items: ["Songs", "Users"])
    
    var childVC2 = TrendingViewController()
    var childVC1 = FeedViewController(nibName: "FeedViewController", bundle: nil)

    var searchController: TrackSearchController!
    var searchResultsController: SearchTrackResultsViewController!
    var preserveTitleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add Songs/Users option element to the navbar
        options.selectedSegmentIndex = 0
        options.tintColor = UIColor.grayColor()
        options.addTarget(self, action: "switchTable", forControlEvents: .ValueChanged)
//        navigationItem.titleView = options
        
        navigationItem.title = "Songs"
        addPlusButton()
        
        addChildViewController(childVC1)
        childVC1.view.frame = view.bounds
        view.addSubview(childVC1.view)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 181.0 / 255.0, green: 87.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
//        navigationController?.navigationBar.translucent = true
        
        // Arbitrary additions for SWRevealVC
        revealViewController().panGestureRecognizer()
        revealViewController().tapGestureRecognizer()
        
    }
    
    func switchTable() {
        if (options.selectedSegmentIndex == 1 && childViewControllers[0] as! NSObject == childVC1) {
            childVC1.view.removeFromSuperview() //Removes it from view
            childVC1.removeFromParentViewController() //Removes it as child
            childVC2.view.frame = view.bounds
            addChildViewController(childVC2) //Adds as child
            view.addSubview(childVC2.view) //Adds to view
        } else if (options.selectedSegmentIndex == 0 && childViewControllers[0] as! NSObject == childVC2) {
            childVC2.view.removeFromSuperview()
            childVC2.removeFromParentViewController()
            addChildViewController(childVC1)
            childVC1.view.frame = view.bounds
            view.addSubview(childVC1.view)
        }
    }

    func addPlusButton() {
        // Add plus sign to the right side of the navbar
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "initializePostCreation")
        navigationItem.rightBarButtonItem = button
    }

    func initializePostCreation() {
        searchResultsController = SearchTrackResultsViewController() as SearchTrackResultsViewController
        
        searchController = TrackSearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.delegate = self
        searchController.parent = self
        searchResultsController.delegate = self
        definesPresentationContext = true
        
        preserveTitleView = navigationItem.titleView
        navigationItem.titleView = searchController.searchBar
        navigationItem.rightBarButtonItem = nil
        
        delay(0.05) {
            self.searchController.searchBar.becomeFirstResponder()
            return
        }
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        navigationItem.titleView = preserveTitleView
        addPlusButton()
    }
    
    func selectSong(track: TrackResult) {
        searchController?.showResultSelection(track)
    }
    
    func postSong(track: TrackResult) {
        closeSearchView()
        childVC1.addSong(track)
        searchController.active = false
        
        searchResultsController.finishSearching()
        
        println("TODO: add this track")
        println(track)
    }
    
    func closeSearchView() {
        searchController?.searchBar.text = ""
        searchController?.searchBar.resignFirstResponder()
        searchResultsController.finishSearching()
    }
}