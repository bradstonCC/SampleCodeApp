//
//  SampleViewController.swift
//  SampleCodeApp
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadCountrySampleDataFile()
    }
    
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
    
    func loadCountrySampleDataFile() {
        //Load Country Code file stored in app file system into app
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

}
