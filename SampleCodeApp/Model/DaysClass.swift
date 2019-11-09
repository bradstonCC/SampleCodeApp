//
//  DaysClass.swift
//
//  Created by Bradston Henry on 10/24/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import SwiftyJSON
import UIKit

enum DaysClass {
    
    /**
    Parse session Data retrieved from Network request and assign it's data to the appropriate model and return the model for use
    
    - Parameter sessionData: Response session data received from a network request
    
    - Returns:
     An array of DayData which holds the parsed session data in the appropriate model for use
    */
    static func parseSessionsResponseData(sessionData: Data) -> [DayData] {
        var jsonOptional: JSON?
         //Convert data from request to JSON object
         jsonOptional = try? JSON(data: sessionData)
        
         //Unwrap and ensure JSON is valid and days data exists in JSON object
         guard let json = jsonOptional else {return []}
         guard let days = json["days"].dictionary else {return []}
         //Will store all days Objects in format we desire
         var daysDataArray: [DayData] = []
         
         //Iterate over days in JSON object
         for day in days {
             //Unwrap day and session object
             guard let dayJSON = days[day.key] else {return []}
             
             //Setup up Day Data obj for storing day data
             let dayData = DayData.init(withJSON: dayJSON, withDateString: day.key)

             //Add day data to daysData array
             daysDataArray.append(dayData)
         }
        //Order days Data from newest to oldest
        let sortedDaysDataArray = daysDataArray.sorted(by: { ($0.date ?? "") > ($1.date ?? "")})
        
        return sortedDaysDataArray
        
    }
    
    /**
    Converts a UTC date string into Human Readable "Hour:Minute AM/PM" format
    
    - Parameter utcDateString: UTC date in string format
    
    - Returns:
     Formatted Date string in "h:mm a" format. E.g. 592066800 -> 3:00 PM
    */
    static func convertUTCTimeStringToLocalTime(utcDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = .current
        guard let doubleUTCDateVal = Double(utcDateString) else {return utcDateString}
        let utcDate = Date(timeIntervalSince1970: doubleUTCDateVal)
        let localDateString = dateFormatter.string(from: utcDate)
        
        return localDateString
    }
    
    /**
    Converts a  session date string from "yyyyMMdd" format to "MMMM d, yyyy" format
    
    - Parameter sessionDate: String with Session Date in "yyyyMMdd" format
    
    - Returns:
     Formatted Date string in "MMMM d, yyyy" format. E.g. 19881005 -> October 5th, 1988
    */
    static func convertSessionDateForDisplay(sessionDate: String) -> String {
        let origDateFormatter = DateFormatter()
        origDateFormatter.dateFormat = "yyyyMMdd"
        origDateFormatter.timeZone = .current
        
        guard let origDate = origDateFormatter.date(from: sessionDate)  else {
            return sessionDate
        }
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMMM d, yyyy"
        let newDateString = newDateFormatter.string(from: origDate)
        
        return newDateString
    }
    
    /**
    Converts a UTC date string into Human Readable "Month Day, Year" format
    
    - Parameter utcDateString: UTC date in string format
    
    - Returns:
     Formatted Date string in "MMMM d, yyyy" format. E.g. 592074539 -> October 5th, 1988
    */
    static func convertUTCTimeStringToDateForDisplay(utcDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateFormatter.timeZone = .current
        guard let doubleUTCDateVal = Double(utcDateString) else {return utcDateString}
        let utcDate = Date(timeIntervalSince1970: doubleUTCDateVal)
        let localDateString = dateFormatter.string(from: utcDate)
        
        return localDateString
    }
}
