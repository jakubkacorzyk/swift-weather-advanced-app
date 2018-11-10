//
//  LocationData.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 28/10/2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import Foundation
import UIKit

class LocationData {
    var actualTemp : String
    var imageSign : String
    var img : UIImage
    
    init(actualTemp : String, imageSign : String, img : UIImage){
        self.actualTemp = actualTemp
        self.imageSign = imageSign
        self.img = img
    }
}
