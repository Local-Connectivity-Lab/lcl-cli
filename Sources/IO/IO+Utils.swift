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
import LCLPing
import LCLSpeedtest

internal func generatePingSummary(
    _ pingSummary: PingSummary,
    for type: LCLPing.PingType,
    formats: Set<OutputFormat>
) {
    for format in formats {
        switch format {
        case .json:
            generateSummaryInJSON(summary: pingSummary)
        case .default:
            generatePingSummaryDefault(pingSummary: pingSummary, type: type)
        }
    }
}

internal func generateSpeedTestSummary(
    _ speedTestSummary: SpeedTestSummary,
    kind: TestDirection,
    formats: Set<OutputFormat>,
    unit: MeasurementUnit
) {
    for format in formats {
        switch format {
        case .json:
            generateSummaryInJSON(summary: speedTestSummary)
        case .default:
            generateSpeedTestSummaryDefault(speedTestSummary: speedTestSummary, kind: kind, unit: unit)
        }
    }
}

private func generateSummaryInJSON(summary: Encodable) {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    guard let result = try? jsonEncoder.encode(summary) else {
        print("PingSummary is corrupted and unable to output in JSON format.")
        return
    }

    print(String(data: result, encoding: .utf8)!)
}

private func generatePingSummaryDefault(pingSummary: PingSummary, type: LCLPing.PingType) {
    print("====== Ping Result ======")
    let protocolType = ProtocolType(rawValue: pingSummary.protocol)
    print("Host: \(pingSummary.ipAddress):\(pingSummary.port) [\(protocolType?.string ?? "Unknown Protocol")]")
    print("Total Count: \(pingSummary.totalCount)")

    print("====== Details ======")

    print(pingSummary.details.renderTextTable())

    print("Duplicate: \(pingSummary.duplicates.sorted())")
    print("Timeout: \(pingSummary.timeout.sorted())")

    print("======= Statistics =======")
    print("Min: \(pingSummary.min.round(to: 2)) ms")
    print("Max: \(pingSummary.max.round(to: 2)) ms")
    print("Jitter: \(pingSummary.jitter.round(to: 2)) ms")
    print("Average: \(pingSummary.avg.round(to: 2)) ms")
    print("Medium: \(pingSummary.median.round(to: 2)) ms")
    print("Standard Deviation: \(pingSummary.stdDev.round(to: 2)) ms")
}

private func generateSpeedTestSummaryDefault(
    speedTestSummary: SpeedTestSummary,
    kind: TestDirection,
    unit: MeasurementUnit
) {
    print("====== SpeedTest Result ======")
    print("Type: \(kind)")
    print("Total Count: \(speedTestSummary.totalCount)")

    print("====== Details ======")

    print(speedTestSummary.details.renderTextTable())

    print("======= Statistics =======")
    print("Min: \(speedTestSummary.min.round(to: 2)) \(unit.string)")
    print("Max: \(speedTestSummary.max.round(to: 2)) \(unit.string)")
    print("Jitter: \(speedTestSummary.jitter.round(to: 2)) \(unit.string)")
    print("Average: \(speedTestSummary.avg.round(to: 2)) \(unit.string)")
    print("Medium: \(speedTestSummary.median.round(to: 2)) \(unit.string)")
    print("Standard Deviation: \(speedTestSummary.stdDev.round(to: 2)) \(unit.string)")
    print("Latency: \(speedTestSummary.latency.round(to: 2)) ms")
    print("Latency Variance: \(speedTestSummary.latencyVariance.round(to: 2)) ms")
    print("Retransmit Rate: \((speedTestSummary.retransmit * 100.0).round(to: 2)) %")
}
