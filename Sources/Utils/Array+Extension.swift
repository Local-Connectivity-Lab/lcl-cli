//
// This source file is part of the LCLPing open source project
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

extension Array where Element == SpeedTestElement {

    /// Average of the given array of `PingResult`
    var avg: Double {
        if isEmpty {
            return 0.0
        }

        let sum = reduce(0.0) { partialResult, measurementResult in
            partialResult + measurementResult.speed
        }
        
        return sum / Double(count)
    }
    
    /// Median of the given array of `PingResult`
    var median: Double {
        if isEmpty {
            return 0
        }
        
        let sorted = sorted { $0 < $1 }
        if count % 2 == 1 {
            // odd
            return sorted[count / 2].speed
        } else {
            // even - lower end will be returned
            return sorted[count / 2 - 1].speed
        }
        
    }
    
    /// Standard Deviation of the given array of `PingResult`
    var stdDev: Double {
        if isEmpty || count == 1 {
            return 0.0
        }
        
        return sqrt(map { ($0.speed - avg) * ($0.speed - avg) }.reduce(0.0, +) / Double(count - 1))
    }
}
