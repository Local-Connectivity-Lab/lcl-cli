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
import LCLSpeedTest

/// The network measurement unit used by the speed test framework
enum MeasurementUnit: String, CaseIterable, Identifiable, Encodable {

    case Mbps
    case MBps

    var id: Self {self}

    var string: String {
        switch self {
        case .Mbps:
            return "mbps"
        case .MBps:
            return "MB/s"
        }
    }
}

extension MeasurementProgress {

    /// data in Mbps
    var defaultValueInMegaBits: Double {
        get {
            self.convertTo(unit: .Mbps)
        }
    }

    /// data in MB/s
    var defaultValueInMegaBytes: Double {
        get {
            self.convertTo(unit: .MBps)
        }
    }

    /**
     Convert the measurement data to the given unit
     
     - Parameters:
        unit: the target unit to convert to
     - Returns: the value in `Double` under the specified unit measurement
     */
    func convertTo(unit: MeasurementUnit) -> Double {
        let elapsedTime = appInfo.elapsedTime
        let numBytes = appInfo.numBytes
        let time = Float64(elapsedTime) / 1000000
        var speed = Float64(numBytes) / time
        switch unit {
        case .Mbps:
            speed *= 8
        case .MBps:
            speed *= 1
        }

        speed /= 1000000
        return speed
    }
}

internal func prepareSpeedTestSummary(data: [MeasurementProgress], unit: MeasurementUnit) -> SpeedTestSummary {
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
