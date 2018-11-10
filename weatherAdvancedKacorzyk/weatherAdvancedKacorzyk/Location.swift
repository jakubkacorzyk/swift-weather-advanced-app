//
//  Location.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 28/10/2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import Foundation

class Location {
    var name : String
    var locationData : LocationData
    
    init(name : String, locationData : LocationData) {
        self.name = name
        self.locationData = locationData
    }
}
