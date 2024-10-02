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
import LCLSpeedtest

/// The network measurement unit used by the speed test framework
enum MeasurementUnit: String, CaseIterable, Identifiable, Encodable {

    case Mbps
    case MBps

    var id: Self {self}

    var string: String {
        switch self {
        case .Mbps:
            return "Mbit/s"
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

internal func prepareSpeedTestSummary(data: [MeasurementProgress], tcpInfos: [TCPInfo], for: TestDirection, unit: MeasurementUnit) -> SpeedTestSummary {
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

    let tcpMeasurement = computeLatencyAndRetransmission(tcpInfos, for: `for`)

    let jitter = data.isEmpty ? 0.0 : consecutiveDiffSum / Double(data.count)
    return SpeedTestSummary(min: localMin,
                            max: localMax,
                            avg: avg,
                            median: median,
                            stdDev: stdDev,
                            jitter: jitter,
                            details: measurementResults,
                            latency: tcpMeasurement.latency,
                            latencyVariance: tcpMeasurement.variance,
                            retransmit: tcpMeasurement.retransmit,
                            totalCount: data.count
                            )
}

internal func computeLatencyAndRetransmission(_ tcpInfos: [TCPInfo], for direction: TestDirection) -> (latency: Double, variance: Double, retransmit: Double) {
    if tcpInfos.isEmpty {
        return (0, 0, 0)
    }
    var latency: Int64 = 0
    var latencyVariance: Int64 = 0
    var retransmit: Int64 = 0
    var total: Int64 = 0
    tcpInfos.forEach { tcpInfo in
        latency += tcpInfo.rtt ?? 0
        latencyVariance += tcpInfo.rttVar ?? 0
        retransmit += tcpInfo.bytesRetrans ?? 0
        switch direction {
        case .download:
            total += tcpInfo.bytesSent ?? 0
        case .upload:
            total += tcpInfo.bytesReceived ?? 0
        }
    }

    return (Double(latency / 1000) / Double(tcpInfos.count), Double(latencyVariance / 1000) / Double(tcpInfos.count), Double(retransmit) / Double(total))
}
