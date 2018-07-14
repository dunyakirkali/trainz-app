//
//  Train.swift
//  trainz
//
//  Created by Dunya Kirkali on 14/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import Foundation
import CoreLocation

class Train {
    /// Top speed for a train
    static let topSpeed: Measurement<UnitSpeed> = Measurement<UnitSpeed>(value: 500, unit: .kilometersPerHour)
    
    /// Speed in km/h
    var speed: Measurement<UnitSpeed> = Measurement<UnitSpeed>(value: 0, unit: .kilometersPerHour)
    
    /// Location as CLLocationCoordinate2D
    var location: CLLocationCoordinate2D
    
    init(location: CLLocationCoordinate2D) {
        self.location = location
    }
}
