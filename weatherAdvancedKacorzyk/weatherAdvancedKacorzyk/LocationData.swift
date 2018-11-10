//
//  LocationData.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 28/10/2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import Foundation

class LocationData {
    var actualTemp : String
    var imageSign : String
    
    init(actualTemp : String, imageSign : String) {
        self.actualTemp = actualTemp
        self.imageSign = imageSign
    }
}
