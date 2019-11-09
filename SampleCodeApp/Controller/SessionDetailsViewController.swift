//
//  SessionDetailsViewController.swift
//  SampleCodeApp
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class SessionDetailsViewController: UIViewController {

    let allowedSegues = ["unwindSegueToSampleViewController"]
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        SegueClass.toSampleViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Check if current called segue is allowed with this VC
        return SegueClass.isSegueAllowed(allowedSegues: allowedSegues, segueID: identifier)
    }

}
