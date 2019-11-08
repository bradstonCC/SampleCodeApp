//
//  SessionData.swift
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import SwiftyJSON
import UIKit

struct SessionData {
    var sessionStart: String?
    var sessionEnd: String?
    var sessionLabel: String?
    var zones: [ZoneData] = []
    
    init(withJSON sessionJSON: JSON) {
        guard let zonesDictionary = sessionJSON["zones"].dictionary else {return}
        
        var zoneDataArray: [ZoneData] = []
        
        for zone in zonesDictionary {
            
            let zoneJSON = zone.value
            //Create Zone Data from Json data
            let zoneData = ZoneData.init(withJSON: zoneJSON)
            
            //Add Zone data to Session Zones Data Array
           zoneDataArray.append(zoneData)
        }
        
        //Order zones from newest to oldest
        self.zones = zoneDataArray.sorted(by: {($0.zoneStart ?? "") > ($1.zoneStart ?? "")})
        //Add Session Info to Session Data Object
        self.sessionStart = sessionJSON["sessionStart"].string
        self.sessionEnd = sessionJSON["sessionEnd"].string
        self.sessionLabel = sessionJSON["sessionLabel"].string
    }
}
