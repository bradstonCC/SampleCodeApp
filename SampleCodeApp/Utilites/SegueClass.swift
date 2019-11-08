//
//  SegueClass.swift
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class SegueClass: NSObject {
    
    // MARK: - View Controller Segues
    
    class func toDesiredVC() {
        let unwindSegueExists = doesUnwindSegueExist(myCustomClass: SampleViewController.self)
        
        if unwindSegueExists {
            shouldSegueBePerformed(segueID: "unwindSegueToViewController")
        } else {
            shouldSegueBePerformed(segueID: "ToViewController")
        }
    }
    
    // MARK: - Segue Utility Functions
    
    class func doesUnwindSegueExist<T>(myCustomClass: T.Type) -> Bool {
        
        guard let navCon = getRootNavigationController() else {return false}
        //Check to see if any View controllers in nav hiearchy match desired Class...
        for viewController in navCon.viewControllers {
            if viewController is T {
                //If so, return true to initiate an unwind segue
                return true
            }
        }
        //If not, do not try to initiate an unwind segue
        return false
    }
    
    class func shouldSegueBePerformed(segueID: String) {
        DispatchQueue.main.async {
            let visibleVC = getVisibleViewControllerfromNavController()
            //Call should perform segue delegate function that exists in View controller
            if visibleVC.shouldPerformSegue(withIdentifier: segueID, sender: self) {
                visibleVC.performSegue(withIdentifier: segueID, sender: self)
            }
        }
    }
    
    // MARK: - Navigation Controller Functions
    
    class func getRootNavigationController() -> UINavigationController? {
        guard let appDel = UIApplication.shared.delegate else { return nil}
        guard let window = appDel.window else {return nil}
        return window?.rootViewController as? UINavigationController
    }

    class func getVisibleViewControllerfromNavController() -> UIViewController {
        //Retrieve root navigation controller from appDelegate
        guard let navVC = getRootNavigationController()  else {
            return UIViewController()
        }
        
        //Retrive visible view controller
        guard var visibleVC = navVC.visibleViewController else {
            return UIViewController()
        }
        
        //If visible view controller is an alert controller, move down view hierarchy one level to get visible VC
        if visibleVC is UIAlertController {
            visibleVC = navVC.viewControllers[navVC.viewControllers.count - 1]
        }
        
        return visibleVC
    }
    
    class func doesSegueExist(selectedVC: UIViewController, segueID: String) -> Bool {
        //Find the Segue Templates in ViewController
        guard let segueTemplates = selectedVC.value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false}
        //Search through segue Templates to see if desired segue exists ( returns nil if it doesnt exist)
        let foundSegue = segueTemplates.first { $0.value(forKey: "identifier") as? String == segueID }
        
        //Check if nil. Return false if nil
        if foundSegue != nil {
            return false
        }
        
        return true
    }
    
    class func isSegueAllowed(allowedSegues: [String], segueID: String) -> Bool {
        //Checks all allowed segues in VC against segue identifier being called
        for segue in allowedSegues {
            if segue == segueID {
                return true
            }
        }
        //If it is not in the array, it is not allowed
        return false
    }
    
}
