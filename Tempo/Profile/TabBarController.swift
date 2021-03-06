
import UIKit

class TabBarController: UIViewController, NotificationDelegate, UIGestureRecognizerDelegate {
	
	static let sharedInstance = TabBarController()
    
    var numberOfTabs: Int = 0
    var tabBarContainerView = UIView()
    var tabBarButtons = [UIButton]()
    var transparentTabBarEnabled: Bool = false
    var tabBarButtonFireEvent: UIControlEvents = .touchDown
    
    var selectedBarButtonImages = [Int:UIImage]()
    var unSelectedBarButtonImages = [Int:UIImage]()
    
    var currentlyPresentedViewController: UIViewController?
    var accessoryViewController: TabBarAccessoryViewController?
    
    var tabBarIsHidden: Bool = false
	
	let notificationTabBanner = UIView()
	let notificationBannerImage = UIImageView()
	let notificationTabIndicator = UIView()
	var unreadNotificationCount: Int = 0 {
		didSet {
			updateNotificationTabIndicator()
		}
	}
    
    // Tab to present on viewDidLoad
    var preselectedTabIndex = 0
    
    var tabBarColor: UIColor = .black {
        didSet {
            tabBarContainerView.backgroundColor = tabBarColor
        }
    }

    var blocksToExecuteOnTabBarButtonPress = [Int:() -> ()]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        createTabBarContainerView()
        setupTabs()
        
        programmaticallyPressTabBarButton(atIndex: preselectedTabIndex)
    }
    
    func createTabBarContainerView() {
        
        tabBarContainerView = UIView(frame: CGRect(x: 0, y: view.frame.height - tabBarHeight, width: view.frame.width, height: tabBarHeight))
        tabBarContainerView.backgroundColor = tabBarColor

        view.addSubview(tabBarContainerView)
    }
    
    func setupTabs() {
        
        let tabBarButtonWidth = view.frame.width / CGFloat(numberOfTabs)
        var xOffset: CGFloat = 0.0
		for i in 0 ..< numberOfTabs {
			
			// Initialize notification tab indicator and banner
			if i == 3 {
				notificationTabBanner.frame = CGRect(x: xOffset, y: -tabBarHeight, width: tabBarButtonWidth, height: tabBarHeight)
				notificationTabBanner.backgroundColor = .clear
				notificationTabBanner.layer.opacity = 0
				
				notificationBannerImage.frame = CGRect(x: 10, y: 20, width: tabBarButtonWidth-20, height: tabBarHeight-14)
				notificationBannerImage.image = #imageLiteral(resourceName: "LikeAlert")
				
				notificationTabBanner.addSubview(notificationBannerImage)
				
				tabBarContainerView.addSubview(notificationTabBanner)
				tabBarContainerView.clipsToBounds = false
				
				let frame = CGRect(x: xOffset, y: 0, width: tabBarButtonWidth, height: tabBarHeight)
				let notificationTabView = UIView(frame: frame)
				notificationTabView.backgroundColor = .clear
				notificationTabView.isUserInteractionEnabled = false
				
				notificationTabIndicator.frame = CGRect(x: (frame.width/2) - 2.5, y: frame.height - 10, width: 5, height: 5)
				notificationTabIndicator.backgroundColor = .tempoRed
				notificationTabIndicator.layer.cornerRadius = 2.5
				notificationTabIndicator.isHidden = true
				
				notificationTabView.addSubview(notificationTabIndicator)
				tabBarContainerView.addSubview(notificationTabView)
			}
			
            let newTabBarButton = UIButton(frame: CGRect(x: xOffset,
                                                         y: 0,
                                                         width: tabBarButtonWidth,
                                                         height: tabBarHeight))
            
            newTabBarButton.backgroundColor = .clear
            
            newTabBarButton.addTarget(self, action: #selector(didPressTabBarButton(tabBarButton:)), for: tabBarButtonFireEvent)
            
            newTabBarButton.setImage(selectedBarButtonImages[i], for: .selected)
            newTabBarButton.setImage(unSelectedBarButtonImages[i], for: .normal)
            
            tabBarContainerView.addSubview(newTabBarButton)
            
			tabBarButtons.append(newTabBarButton)
			
            xOffset += tabBarButtonWidth
        }
        
    }
    
    func didPressTabBarButton(tabBarButton: UIButton) {
        
        guard let tabBarButtonIndex = tabBarButtons.index(of: tabBarButton) else { return }
        
        for button in tabBarButtons {
            button.isSelected = false
        }
        
        tabBarButton.isSelected = true
        
        if let blockToExecute = blocksToExecuteOnTabBarButtonPress[tabBarButtonIndex] {
            blockToExecute()
        }
    }
    
    func programmaticallyPressTabBarButton(atIndex index: Int) {
        
        for button in tabBarButtons {
            button.isSelected = false
        }
        
        tabBarButtons[index].isSelected = true
        
        if let blockToExecute = blocksToExecuteOnTabBarButtonPress[index] {
            blockToExecute()
        }
    }
    
    func setSelectedImage(image: UIImage, forTabAtIndex index: Int) {
        selectedBarButtonImages[index] = image
    }
    
    func setUnselectedImage(image: UIImage, forTabAtIndex index: Int) {
        unSelectedBarButtonImages[index] = image
    }
    
    func addBlockToExecuteOnTabBarButtonPress(block: @escaping () -> (), forTabAtIndex index: Int) {
        blocksToExecuteOnTabBarButtonPress[index] = block
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        currentlyPresentedViewController?.willMove(toParentViewController: nil)
        currentlyPresentedViewController?.view.removeFromSuperview()
        currentlyPresentedViewController?.removeFromParentViewController()
        currentlyPresentedViewController = nil
        
        viewControllerToPresent.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        if let localAccessoryViewController = accessoryViewController {
            view.insertSubview(viewControllerToPresent.view, belowSubview: localAccessoryViewController.view)
        } else {
            view.insertSubview(viewControllerToPresent.view, belowSubview: tabBarContainerView)
        }
        
        addChildViewController(viewControllerToPresent)
        viewControllerToPresent.didMove(toParentViewController: self)
        currentlyPresentedViewController = viewControllerToPresent
        
        completion?()
    }
    
    func addAccessoryViewController(accessoryViewController: TabBarAccessoryViewController) {
        
        self.accessoryViewController?.willMove(toParentViewController: nil)
        self.accessoryViewController?.view.removeFromSuperview()
        self.accessoryViewController?.removeFromParentViewController()
        self.accessoryViewController = nil
        
        accessoryViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.insertSubview(accessoryViewController.view, belowSubview: tabBarContainerView)
        addChildViewController(accessoryViewController)
        accessoryViewController.didMove(toParentViewController: self)
        self.accessoryViewController = accessoryViewController
    }
    
    func showTabBar(animated: Bool) {
        
        if !tabBarIsHidden { return }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.tabBarContainerView.frame = CGRect(x: 0, y: self.view.frame.height - self.tabBarContainerView.frame.height, width: self.tabBarContainerView.frame.width, height: self.tabBarContainerView.frame.height)
            })
        } else {
            tabBarContainerView.frame = CGRect(x: 0, y: view.frame.height - tabBarContainerView.frame.height, width: tabBarContainerView.frame.width, height: tabBarContainerView.frame.height)
        }
        
        tabBarIsHidden = false
    }
    
    func hideTabBar(animated: Bool) {
        
        if tabBarIsHidden { return }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.tabBarContainerView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.tabBarContainerView.frame.width, height: self.tabBarContainerView.frame.height)
            })
        } else {
            tabBarContainerView.frame = CGRect(x: 0, y: view.frame.height, width: tabBarContainerView.frame.width, height: tabBarContainerView.frame.height)
        }
        
        tabBarIsHidden = true
    }
	
	// Animate notification banner with proper image
	func animateNotificationTabBanner(forNotificationType type: NotificationType) {
		let hideCompletion: (Bool) -> Void = { _ in
			UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseInOut, animations: {
				self.notificationTabBanner.layer.opacity = 0
			}, completion: nil)
		}
		
		notificationBannerImage.image = (type == .Like) ? #imageLiteral(resourceName: "LikeAlert") : #imageLiteral(resourceName: "FollowerAlert")
		
		UIView.animate(withDuration: 0.2, animations: {
			self.notificationTabBanner.layer.opacity = 1.0
		}, completion: hideCompletion)
		
		unreadNotificationCount += 1
	}
	
	// Show and hide notification tab indicator
	func updateNotificationTabIndicator() {
		notificationTabIndicator.isHidden = (unreadNotificationCount < 1)
	}
	
	// MARK: - Notification Delegate
	
	func showNotificationBanner(_ userInfo: [AnyHashable : Any]) {
		let info = (userInfo[AnyHashable("custom")] as! NSDictionary).value(forKey: "a") as! NSDictionary
		print(userInfo)
		if info.value(forKey: "notification_type") as! Int == 1 {
			// Liked song notification
			Banner.showBanner(
				self,
				delay: 0.5,
				data: TempoNotification(msg: info.value(forKey: "message") as! String, type: .Like),
				backgroundColor: .white,
				textColor: .black,
				delegate: self)
		} else if info.value(forKey: "notification_type") as! Int == 2 {
			// New user follower
			Banner.showBanner(
				self,
				delay: 0.5,
				data: TempoNotification(msg: info.value(forKey: "message") as! String, type: .Follower),
				backgroundColor: .white,
				textColor: .black,
				delegate: self)
		} else {
			// Generic notification - do nothing
			return
		}
	}
	
	func didTapNotification(forNotification notif: TempoNotification, cell: NotificationTableViewCell?, postHistoryVC: PostHistoryTableViewController?) {
		print("Tapped notification")
		if notif.type == .Like, let postID = notif.postId {
			if let vc = postHistoryVC {
				var row: Int = 0
				for p in vc.posts {
					if p.postID == postID { break }
					row += 1
				}
				vc.sectionIndex = vc.relativeIndexPath(row: row).section
				vc.rowIndex = vc.relativeIndexPath(row: row).row
				self.present(vc, animated: true)
			} else {
				print("Needs to be implemented -- access global profile history VC?")
			}
		} else if notif.type == .Follower, let user = notif.user {
			let profileVC = ProfileViewController()
			profileVC.title = "Profile"
			profileVC.user = user
			self.present(profileVC, animated: true)
		}
		
		
	}
}
