//
//  Train.swift
//  trainz
//
//  Created by Dunya Kirkali on 14/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import Foundation

class Train {
    /// Top speed for a train
    static let topSpeed: Measurement<UnitSpeed> = Measurement<UnitSpeed>(value: 500, unit: .kilometersPerHour)
    
    /// Speed in km/h
    var speed: Measurement<UnitSpeed> = Measurement<UnitSpeed>(value: 0, unit: .kilometersPerHour)
}
