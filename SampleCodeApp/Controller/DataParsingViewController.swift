//
//  DataParsingViewController.swift
//  SampleCodeApp
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

class DataParsingViewController: UIViewController {

    @IBOutlet weak var rawJSONInputField: UITextView!
    
    @IBOutlet weak var parsedDayDataInputField: UITextView!
    
    @IBOutlet weak var aggregatedDashboardDataInputField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let textBorderColor: UIColor = .black
        rawJSONInputField.layer.borderColor = textBorderColor.cgColor
        rawJSONInputField.layer.borderWidth = 2.0
        parsedDayDataInputField.layer.borderColor = textBorderColor.cgColor
        parsedDayDataInputField.layer.borderWidth = 2.0
        aggregatedDashboardDataInputField.layer.borderColor = textBorderColor.cgColor
        aggregatedDashboardDataInputField.layer.borderWidth = 2.0
        
        loadSampleDataFile()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Data Parsing
    
    func loadDaysData(sampleData: Data) {
                
        let daysData = DaysClass.parseSessionsResponseData(sessionData: sampleData)
        
        //Display one element Dahsboard Data array for view
        if daysData.count > 0 {
            if let sampleDay = daysData.first {
                parsedDayDataInputField.text = "\(sampleDay)"
            }
        }
        
        let dashboardDaysData = getDashboardDaysData(withDaysData: daysData)
        
        let filteredDashboardData = DashboardDataClass.getFilteredDashboardData(withTimeframe: .last30Days, dashboardDaysData: dashboardDaysData)
        
        
        
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
        
        //Display one element Dahsboard Data array for view
        if dDaysDataArray.count > 0 {
            if let sampleDDaysData = dDaysDataArray.first {
                aggregatedDashboardDataInputField.text = "\(sampleDDaysData)"
            }
        }
        
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
                
                let jsonText = String(decoding: urlAsData, as: UTF8.self)
                rawJSONInputField.text = jsonText
                
                AlertViewManager.singleButtonAlertViewControllerWithTitle(title: "Sample Data Successfully Loaded", withMessage: "JSON sample data was able to be loaded for parsing", withButtonTitle: "Okay")
            } catch {
                print("Error Occurred")
            }
        }
        
    }

}
