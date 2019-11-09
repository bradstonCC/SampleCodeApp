//
//  WebViewController.swift
//  MMANow
//
//  Created by Bradston Henry on 10/1/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView:WKWebView!
    var url: URL!
    var articleTitle: String?
    
    @IBOutlet weak var urlText: UILabel!
    @IBOutlet weak var navTitle: UINavigationItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Load Web View
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        //Load article url
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
        
        webView.allowsBackForwardNavigationGestures = true
        
        if let title = articleTitle {
            navTitle.title = title
        } else {
            navTitle.title = url.absoluteString
        }
        
        //Label Height for link url label
        let labelHeight: CGFloat = 40
        
        //Create label that will hold url string for showing user
        let label = UILabel(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - labelHeight, width: UIScreen.main.bounds.width, height: labelHeight))
        
        //Set Attributes of label
        label.textColor = .white
        label.backgroundColor = .gray
        label.text = url.absoluteString
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .center
        
        //Add label to view
        view.addSubview(label)
        //Bring it to the front so it can be seen
        view.bringSubviewToFront(label)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

}
