//
//  DayData.swift
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import SwiftyJSON
import UIKit

struct DayData {
    var date: String?
    var sessions: [SessionData] = []
    
    init(withJSON dayJSON: JSON, withDateString dateString: String) {
        //Set date field of day data obj
        self.date = dateString
        
        var sessionDataArray: [SessionData] = []
        
        guard let sessionsDictionary = dayJSON["sessions"].dictionary else {return}
        
        //create an array of sessions to be added to dayData  object
        for session in sessionsDictionary {
            
            let sessionJSON = session.value
            //Create session data from json data
            let sessionData = SessionData.init(withJSON: sessionJSON)
            //Add session data to day object
            sessionDataArray.append(sessionData)
        }
        //Order sessions from newest to oldest
        self.sessions = sessionDataArray.sorted(by: {($0.sessionStart ?? "") > ($1.sessionStart ?? "")})
        
    }
    
}
