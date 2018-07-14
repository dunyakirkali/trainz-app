//
//  TrainTests.swift
//  trainzTests
//
//  Created by Dunya Kirkali on 14/07/2018.
//  Copyright © 2018 Dunya Kirkali. All rights reserved.
//

import XCTest
@testable import trainz

class TrainTests: XCTestCase {
    
    func testInitialSpeedIsZero() {
        let train = Train()
        let expected = Measurement<UnitSpeed>(value: 0, unit: .kilometersPerHour)
        
        XCTAssert(train.speed == expected)
    }
    
    func testTopSpeed() {
        let expected = Measurement<UnitSpeed>(value: 500, unit: .kilometersPerHour)
        
        XCTAssert(Train.topSpeed == expected)
    }
}

