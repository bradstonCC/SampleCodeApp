//
//  AlertViewManager.swift
//  TRUCE
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class AlertViewManager {

    class func singleButtonAlertViewControllerWithTitle(title: String, withMessage message: String, withButtonTitle buttonTitle: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: buttonTitle, style: .default) {
            (_) in
        }
        
        alert.addAction(defaultAction)
        
        if #available(iOS 13.0, *) {
            //Note: This application does not support multi-Window
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            AlertViewManager.getAlertVC().present(alert, animated: true, completion: nil)
        }
        
    }
    
    class func singleButtonAlertViewControllerWithTitleWithCompletion(title: String, withMessage message: String, withButtonTitle buttonTitle: String, withCompletion completion: @escaping (_ result: Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: buttonTitle, style: .default) {
            (_) in
            //Send that user has pressed button
            completion(true)
        }
        
        alert.addAction(defaultAction)
        
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            AlertViewManager.getAlertVC().present(alert, animated: true, completion: nil)
        }
        
    }
    
    class func multiButtonAlertControllerWithTitle(title: String, withMessage message: String, withAlertActionsArray alertActionsArray: [UIAlertAction], withCancelButton hasCancelButton: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for alertAction in alertActionsArray {
            alert.addAction(alertAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (_) in
        }
        
        alert.addAction(cancelAction)
        
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            AlertViewManager.getAlertVC().present(alert, animated: true, completion: nil)
        }
        
    }
    
    class func alertViewWithInpuFieldWithCompletion(title: String, message: String, buttonTitle: String, placeholderText: String, withCompletion completion: @escaping (_ result: String) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let inputFieldAction = UIAlertAction(title: buttonTitle, style: .default) {
            (_) in
            
            //Get text field contained in alertController
            let textField = alert.textFields?.first
            //If text doesn't exist, return error code text
            guard let inputText = textField?.text else {
                completion("ERROR!")
                return
            }
            //Return text that user input in completion handler
            completion(inputText)
            
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = placeholderText
        }
        
        alert.addAction(inputFieldAction)
        
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            AlertViewManager.getAlertVC().present(alert, animated: true, completion: nil)
        }
        
    }
    
    class func getAlertVC() -> UIViewController {
        //Create Alert Window Overlay (Allows for alertView Controller to not interfere with Nav controlloler View transitions)
        let alertWindow = UIWindow()
        alertWindow.frame = UIScreen.main.bounds
        alertWindow.windowLevel = .alert
        
        //Create View Controller that will be used as rootViewController
        let alertVC = UIViewController()
        alertWindow.rootViewController = alertVC
        alertWindow.screen = UIScreen.main
        alertWindow.isHidden = false
        //Set Background Color to clear so Application can be seen in background
        alertWindow.backgroundColor = .clear
        
        return alertVC
    }
}
