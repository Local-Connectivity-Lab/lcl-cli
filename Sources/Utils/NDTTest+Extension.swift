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

internal func prepareSpeedTestSummary(data: [NDT7Measurement], unit: NDT7MeasurementUnit) -> SpeedTestSummary {
    var localMin: Double = .greatestFiniteMagnitude
    var localMax: Double = .zero
    var consecutiveDiffSum: Double = .zero
    
    var measurementResults = [SpeedTestElement]()
    
    
    for i in 0..<data.count {
        let measurement = data[i]
        let res = measurement.convertTo(unit: unit)
        localMin = min(localMin, res)
        localMax = max(localMax, res)
        if i >= 1 {
            consecutiveDiffSum += abs(res - measurementResults.last!.speed)
        }
        measurementResults.append(SpeedTestElement(seqNum: i, speed: res, unit: unit))
    }

    let avg = measurementResults.avg
    let stdDev = measurementResults.stdDev
    let median = measurementResults.median
    let jitter = data.isEmpty ? 0.0 : consecutiveDiffSum / Double(data.count)
    return SpeedTestSummary(min: localMin, 
                            max: localMax,
                            avg: avg, 
                            median: median,
                            stdDev: stdDev,
                            jitter: jitter, 
                            details: measurementResults,
                            totalCount: data.count
                            )
}
