//
//  ZoneData.swift
//
//  Created by Bradston Henry on 11/8/19.
//  Copyright © 2019 Bradston Henry. All rights reserved.
//

import SwiftyJSON
import UIKit

struct ZoneData {
    var zoneStart: String?
    var zoneEnd: String?
    var zoneLabel: String?
    var deviceLabel: String?
    var deviceID: String?
    var miles: Double?
    var utcTimezoneAdjustment: Int?
    var tripID: String?
    var score1: String?
    var score2: String?
    var processed: String?
    
    init(withJSON zoneJSON: JSON) {
        
        //Zone Start can come as a string or an int so we have to handle that issue depending on the case
        var zoneStart = zoneJSON["zoneStart"].string
        if zoneStart == nil {
            guard let zoneStartInt = zoneJSON["zoneStart"].int else {return}
            zoneStart = String(zoneStartInt)
        }
        
        //Assign Zone data to Zone object to be added to Session object
        self.zoneStart = zoneStart
        self.zoneEnd = zoneJSON["zoneEnd"].string
        self.zoneLabel = zoneJSON["zoneLabel"].string
        self.deviceLabel = zoneJSON["devicelabel"].string
        self.deviceID = zoneJSON["deviceid"].string
        self.utcTimezoneAdjustment = zoneJSON["utctimezoneadjustment"].int
        self.miles = zoneJSON["miles"].double
        self.tripID = zoneJSON["tripID"].string
        self.score1 = zoneJSON["score1"].string
        self.score2 = zoneJSON["score2"].string
        self.processed = zoneJSON["processed"].string
        
        
    }
}
