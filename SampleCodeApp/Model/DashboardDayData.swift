//
//  DashboardDayData.swift
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import UIKit

struct DashboardDayData {
    
    private let secondsInHour: Double = 3_600
    private let hoursInDay: Int = 24

    var date: String = ""
    var secondsPerZone: [String: Int] = [:] // Total Hours
    var timeslotPerZone: [String: [Double]] = [:] //Holds seconds spent in zone per hour timeslot
    var milesPerZone: [String: Double] = [:] //Total miles per zone type
    var avgScore1PerZone: [String: Int] = [:] //Average score type 1 per zone type
    var totalDaySecondsInAllZones: Int = 0 //Total seconds spent in all zone for day
    
}

//Extension allows for default and custom DashboardDayData initialzers
extension DashboardDayData {
    
    init(withDayDaya dayData: DayData) {
        
        guard let currentDate = dayData.date else {return}
        var secondsPerZone: [String: Int] = [:] // Total Hours
        var timeslotPerZone: [String: [Double]] = [:] //Holds seconds spend in zone per hour timeslot
        var score1PerZone: [String: [Int]] = [:]
        var milesPerZone: [String: Double] = [:]
        var avgScore1PerZone: [String: Int] = [:]
        var totalDaySecondsInAllZones: Int = 0
        
        //Get unit time array that holds time slots for the specific date passed
        let unixTimeArray = createUnixTimeArray(withDateString: currentDate)
        
        for session in dayData.sessions {
            
            guard let sessionLabel = session.sessionLabel else {continue}
            
            //Must initialize the array inside of dictionary with initialize value
            if secondsPerZone[sessionLabel] == nil {
                secondsPerZone[sessionLabel] = 0
            }
            
            guard let startTime = session.sessionStart, let endTime = session.sessionEnd, let startTimeInt = Int(startTime), let endTimeInt = Int(endTime) else {continue}
            //Grab the current running total of time for zone for totaling
            guard let currentZoneTotal = secondsPerZone[sessionLabel] else {continue}
            
            //Create timeslot array that holds zone time
            let timeslot = setupTimeslotData(unixTimeArray: unixTimeArray, startTime: Double(startTimeInt), endTime: Double(endTimeInt))
            
            //Add timeslot data to dictionary.
            if let timeslotArray = timeslotPerZone[sessionLabel] {
                //If time slot data already exists merge existing array with new time slot array
                let timeslotMerge = zip(timeslot, timeslotArray).map(+)
                timeslotPerZone[sessionLabel] = timeslotMerge
            } else {
                //If time slot data does not exist, assign first set of data to dictionary
                timeslotPerZone[sessionLabel] = []
                timeslotPerZone[sessionLabel] = timeslot
            }
            
            //Calculate total time in zone(seconds)
            let totalSeconds = endTimeInt - startTimeInt
            
            //Keep running total of all zone seconds for total day seconds
            totalDaySecondsInAllZones += totalSeconds
            
            //Add zone time increment into total time (Seconds)
            secondsPerZone[sessionLabel] = currentZoneTotal + totalSeconds
                            
            //Grab score1 from zone data to be averaged later
            for zone in session.zones {
                if let score1 = zone.score1, let score1Int = Int(score1) {
                    //Must initialize the array inside of dictionary with empty array to hold data
                    if score1PerZone[sessionLabel] == nil {
                        score1PerZone[sessionLabel] = []
                    }
                    //Add score 1 to array for averaging
                    score1PerZone[sessionLabel]?.append(score1Int)
                }
                
                if let miles = zone.miles {
                
                    //If no miles data exists in dictionary, initialize miles value
                    if milesPerZone[sessionLabel] == nil {
                        milesPerZone[sessionLabel] = 0
                    }
                    
                    if let currentMilesTotal = milesPerZone[sessionLabel] {
                        //Add current miles total to previous mile total
                        milesPerZone[sessionLabel] = currentMilesTotal + miles
                    }
                }
            }
        }
        
        //Total all score data by zone then average for use
        for zoneScore1 in score1PerZone {
            let score1s = zoneScore1.value
            //Store Average score into dict
            avgScore1PerZone[zoneScore1.key] = averageArrayInt(intArray: score1s)
        }
        
        let orderedSecondsPerZone = secondsPerZone.sorted(by: {($0.value) > ($1.value)})
        
        //Asssign values to data struct
        self.date = currentDate
        self.secondsPerZone = secondsPerZone
        self.timeslotPerZone = timeslotPerZone
        self.milesPerZone = milesPerZone
        self.avgScore1PerZone = avgScore1PerZone
        self.totalDaySecondsInAllZones = totalDaySecondsInAllZones
            
        print("[Dash] Finished Day: \(self)")
        
    }
    
    // MARK: - Utility Functions
    
    func createUnixTimeArray(withDateString sessionDateString: String) -> [Double] {
        //Set up Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = .current
        //Convert session Date String to Date
        guard let currentDate = DashboardDataClass.getDate(withDateString: sessionDateString) else {return []}
        //Convert date to unix time stamp
        let unixTimestamp = DashboardDataClass.getUnixTime(withDate: currentDate)
        //Setup time
        var dateTimeArray: [Double] = []
        //Create 24 hours worth of times for that day (from 00:00 to 24:00) in unix time for that date
        for index in 0...hoursInDay {
            let calculatedUnixTimeStamp = unixTimestamp + (secondsInHour * Double(index))
            dateTimeArray.append(calculatedUnixTimeStamp)
        }
                
        return dateTimeArray
    }
    
    func setupTimeslotData(unixTimeArray: [Double], startTime: Double, endTime: Double) -> [Double] {
        
        var timePerSlot = [Double](repeating: 0, count: hoursInDay)
        
        for (index, currentUnixTime) in unixTimeArray.enumerated() {
            //The unix time for the beginning of the next time slot
            let nextUnixTime = currentUnixTime + secondsInHour
            
            //Entire session takes place in this time slot
            if startTime >= currentUnixTime && endTime < nextUnixTime {
                timePerSlot[index] += endTime - startTime
            }
            
            //If session start time begins mid hour and session time extends beyond that hour
            if startTime >= currentUnixTime && startTime < nextUnixTime  && endTime > nextUnixTime {
                timePerSlot[index] += unixTimeArray[index + 1] - startTime
            }
            
            //If session time encompasses this whole hour, add entire hour to time slot
            if startTime < currentUnixTime && endTime >= nextUnixTime {
                timePerSlot[index] += nextUnixTime - currentUnixTime
            }
            
            //If session end time ends mid hour and session start time proceeded current time slot
            if endTime < nextUnixTime && endTime >= currentUnixTime && startTime < currentUnixTime {
                timePerSlot[index] += endTime - currentUnixTime
            }
            
        }
        
        return timePerSlot
    }
    
    func averageArrayInt(intArray: [Int]) -> Int {
        var total = 0
        for value in intArray {
            total += value
        }
        let avg = total / intArray.count
        return avg
    }
    
}
