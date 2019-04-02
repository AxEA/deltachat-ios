//
//  AppCoordinator.swift
//  deltachat-ios
//
//  Created by Jonas Reinsch on 07.11.17.
//  Copyright © 2017 Jonas Reinsch. All rights reserved.
//

import UIKit

protocol Coordinator {
  func setupViewControllers(window: UIWindow)
}

class AppCoordinator: Coordinator {
  let baseController = BaseController()
  
  private var appTabBarController: AppTabBarController = AppTabBarController()

  func setupViewControllers(window: UIWindow) {
    window.rootViewController = appTabBarController
    window.makeKeyAndVisible()
    
  }
  
  func presentAccountSetup() {
    let accountSetupController = AccountSetupController()
    let accountSetupNavigationController = UINavigationController(rootViewController: accountSetupController)
    appTabBarController.present(accountSetupNavigationController, animated: false, completion: nil)
  }

  func setupInnerViewControllers() {
    let chatListController = ChatListController()
    let chatNavigationController = UINavigationController(rootViewController: chatListController)
    baseController.present(chatNavigationController, animated: false, completion: nil)
  }
  
  /*
  func setupAccountSetup() {
    let accountSetupController = AccountSetupController()
    let accountSetupNavigationController = UINavigationController(rootViewController: accountSetupController)
    baseController.present(accountSetupNavigationController, animated: false, completion: nil)
  }
  */
    
    
    
    
}
