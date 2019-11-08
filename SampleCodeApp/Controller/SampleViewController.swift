//
//  SampleViewController.swift
//  SampleCodeApp
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {
    
    //These are the permitted Segues that user can travel to from this VC
    let allowedSegues = ["ToSessionDetails", "ToHome"]

    
    //MARK: - Actions
    
    @IBAction func toHomePressed(_ sender: Any) {
        
        SegueClass.toHome()
    }
    
    @IBAction func toSessionDetailsPressed(_ sender: Any) {
        
        SegueClass.toSessionDetails()
    }
    
    
    
    // MARK: - Lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Data Parsing
    
    func loadDaysData(sampleData: Data) {
                
        let daysData = DaysClass.parseSessionsResponseData(sessionData: sampleData)
        
        let dashboardDaysData = getDashboardDaysData(withDaysData: daysData)
        
        let filteredDashboardData = DashboardDataClass.getFilteredDashboardData(withTimeframe: .lastDay, dashboardDaysData: dashboardDaysData)
        print(filteredDashboardData)
        
    }
    
    func getDashboardDaysData(withDaysData currentDaysData: [DayData]) -> [DashboardDayData] {
        var dDaysDataArray: [DashboardDayData] = []
        //Create Dashboard data from days Data given
        for currentDay in currentDaysData {
            let dDayData = DashboardDayData.init(withDayDaya: currentDay)
            dDaysDataArray.append(dDayData)
        }
        //Sort Array to make sure days in order by date (descending)
        let sortedDDDArray = dDaysDataArray.sorted(by: {($0.date) > ($1.date)})
        
        return sortedDDDArray
    }
    
    func loadSampleDataFile() {
        //Load Sample Data file stored in app file system into app
        if let path = Bundle.main.path(forResource: "SampleData", ofType: "json") {
            //Get URL from file path for loading data
            let url = URL(fileURLWithPath: path)
               
            do {
                let urlAsData = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                loadDaysData(sampleData: urlAsData)
                AlertViewManager.singleButtonAlertViewControllerWithTitle(title: "Sample Data Successfully Loaded", withMessage: "JSON sample data was able to be loaded for parsing", withButtonTitle: "Okay")
            } catch {
                print("Error Occurred")
            }
        }
        
    }
    
    // MARK: - Segues

    @IBAction func unwindSegueToSampleViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Check if current called segue is allowed with this VC
        return SegueClass.isSegueAllowed(allowedSegues: allowedSegues, segueID: identifier)
    }
    
}
