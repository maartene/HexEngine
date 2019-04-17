//
//  Double+Extension.swift
//  Hex Engine
//
//  Created by Maarten Engels on 16/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

extension Double {
    static func roundToZero(_ value: Double) -> Int {
        if value >= 0 {
            return Int(value)
        } else {
            let intValue = Int(value)
            let difference = value - Double(intValue)
            if difference == 0 {
                return intValue
            } else {
                return intValue - 1
            }
        }
    }
    
    func roundToZero() -> Int {
        return Double.roundToZero(self)
    }
}
