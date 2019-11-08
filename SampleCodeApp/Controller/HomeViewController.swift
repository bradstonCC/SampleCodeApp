//
//  HomeViewController.swift
//  SampleCodeApp
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let allowedSegues = ["unwindSegueToSampleViewController"]

    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        SegueClass.toSampleViewController()
        
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Check if current called segue is allowed with this VC
        return SegueClass.isSegueAllowed(allowedSegues: allowedSegues, segueID: identifier)
    }
    
}
