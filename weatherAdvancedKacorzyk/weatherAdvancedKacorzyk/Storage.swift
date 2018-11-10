//
//  Storage.swift
//  weatherAdvancedKacorzyk
//
//  Created by Jakub  on 28/10/2018.
//  Copyright © 2018 Jakub . All rights reserved.
//

import Foundation

class Storage{
    static let shared : Storage = Storage()
    
    var objects : [Location]
    
    private init(){
        objects = [Location]()
    }
    
}
