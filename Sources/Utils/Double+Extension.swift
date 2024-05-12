//
// This source file is part of the LCL open source project
//
// Copyright (c) 2021-2024 Local Connectivity Lab and the project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
// See CONTRIBUTORS for the list of project authors
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Double {

    /**
     Convert the value from one unit to another unit
     - Parameters:
        - from: the source unit to convert from
        - to: the destination unit to convert to
     - Returns: the equivalent value in the destination unit
     */
    func convertTo(from: MeasurementUnit, to: MeasurementUnit) -> Double {
        var base: Double {
            switch (from, to) {
            case (.Mbps, .Mbps):
                return 1
            case (.MBps, .MBps):
                return 1
            case (.Mbps, .MBps):
                return 1 / 8
            case (.MBps, .Mbps):
                return 8
            }
        }

        return self * base
    }

    /**
     Round the double number to given decimal digits
     
     - Precondition: digit has to be >= 0
     - Parameters:
        - to: the number of decimal digits to round to
     - Returns: the value, rounded to the given digits
     */
    func round(to: Int) -> Double {
        let divisor = pow(10.0, Double(to))
        return (self * divisor).rounded() / divisor
    }
}
