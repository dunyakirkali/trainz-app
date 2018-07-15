//
//  TrainTests.swift
//  trainzTests
//
//  Created by Dunya Kirkali on 14/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import XCTest
import CoreLocation
@testable import trainz

class TrainTests: XCTestCase {
    let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    func testInitialSpeedIsZero() {
        let train = Train(location: location)
        let expected = Measurement<UnitSpeed>(value: 0, unit: .kilometersPerHour)
        
        XCTAssert(train.speed == expected)
    }
    
    func testTopSpeed() {
        let expected = Measurement<UnitSpeed>(value: 500, unit: .kilometersPerHour)
        
        XCTAssert(Train.topSpeed == expected)
    }
}
