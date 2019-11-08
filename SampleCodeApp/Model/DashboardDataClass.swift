//
//  DashboardDataClass.swift
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

enum DashboardTimeFrame {
    case currentDay
    case lastDay
    case last7Days
    case last30Days
}

enum DashboardDataClass {
    
    /**
    Filters array of DashboardDayData objects within the passed time frame and returns the filtered Array
    
    - parameters:
        - timeframe: The enumerated Time frame data needs to be filtered by
        - dashboardDaysData: Array of DashboardDayData object that needs to be filtered
     
    - Returns:
     An array of DashboardDayData objects filtered by given time frame
    */
    static func getFilteredDashboardData(withTimeframe timeframe: DashboardTimeFrame, dashboardDaysData: [DashboardDayData]) -> [DashboardDayData] {
        
        let secondsInADay: Double = 86_400 //Number of seconds in 24 hour day
        
        //Set up Date Formatter to convert "Todays" date to unix Time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = .current
        //Convert Todays date to formatted String
        let dateString = dateFormatter.string(from: Date())
        //Convert back to Date using formatted string (In order to get 00:00 Unix time for current day. Needed for filtering data)
        let currentDate = dateFormatter.date(from: dateString)
        
        //Convert date to unix time stamp
        guard let currentDateTimestamp = currentDate?.timeIntervalSince1970 else {return []}
        
        var endTimeStamp: Double = 0
        var checkForLastDay = false
        
        //Set the end range of time for filtering which Dashboard data to use
        switch timeframe {
        case .currentDay:
            endTimeStamp = currentDateTimestamp
        case .lastDay:
            checkForLastDay = true
            endTimeStamp = currentDateTimestamp - secondsInADay
        case .last7Days:
            endTimeStamp = currentDateTimestamp - (7 * secondsInADay)
        case .last30Days:
            endTimeStamp = currentDateTimestamp - (30 * secondsInADay)
        }
        
        var tempDashboardDaysData: [DashboardDayData] = []
        
        //Go through all dashboard data and filter out the data for days that we desire
        for dashboardDay in dashboardDaysData {
            
            guard let tempDate = DashboardDataClass.getDate(withDateString: dashboardDay.date) else {return []}
            let tempUnixTimestamp = DashboardDataClass.getUnixTime(withDate: tempDate)
            
            //Only add Dashboard day data that fits within desired time frame
            if tempUnixTimestamp >= endTimeStamp {
                //Add dashbord data to filtered array
                tempDashboardDaysData.append(dashboardDay)
                
                //If date matches requirements for last day, end loop over Dashboard Day
                if checkForLastDay && tempUnixTimestamp != currentDateTimestamp {
                    break
                } else if checkForLastDay {
                    //If dashboard data matches current day data, remove and look for the "next" last day
                    tempDashboardDaysData = []
                    endTimeStamp -= secondsInADay
                }
            }
            
        }
        
        return tempDashboardDaysData
    }

    
    // MARK: - Utilities
    
    static func getDate(withDateString sessionDateString: String) -> Date? {
        //Set up Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = .current
        //Convert session Date String to Date
        guard let currentDate = dateFormatter.date(from: sessionDateString)  else {
            return nil
        }
        return currentDate
    }
    
    static func getUnixTime(withDate date: Date) -> Double {
        //Convert date to unix time stamp
        let unixTimestamp = date.timeIntervalSince1970
        return unixTimestamp
    }
    
}
