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
import Yams
import LCLPing

internal func generatePingSummary(_ pingSummary: PingSummary, for type: LCLPing.PingConfiguration.PingType, formats: Set<OutputFormat>) {
    for format in formats {
        switch format {
            case .json:
            generateSummaryInJSON(summary: pingSummary)
            case .yaml:
            generateSummaryInYAML(summary: pingSummary)
            case .default:
            generatePingSummaryDefault(pingSummary: pingSummary, type: type)
        }
    }
}

internal func generateSpeedTestSummary(_ speedTestSummary: SpeedTestSummary, kind: NDT7TestConstants.Kind, formats: Set<OutputFormat>) {
    for format in formats {
        switch format {
            case .json:
            generateSummaryInJSON(summary: speedTestSummary)
            case .yaml:
            generateSummaryInYAML(summary: speedTestSummary)
            case .default:
            generateSpeedTestSummaryDefault(speedTestSummary: speedTestSummary, kind: kind)
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

private func generateSummaryInYAML(summary: Encodable) {
    let yamlEncoder = YAMLEncoder()
    yamlEncoder.options = .init(sortKeys: true)
    guard let result = try? yamlEncoder.encode(summary) else {
        print("PingSummary is corrupted and unable to output in YAML format.")
        return
    }
    print(result)
}

private func generatePingSummaryDefault(pingSummary: PingSummary, type: LCLPing.PingConfiguration.PingType) {
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

private func generateSpeedTestSummaryDefault(speedTestSummary: SpeedTestSummary, kind: NDT7TestConstants.Kind) {
    print("====== SpeedTest Result ======")
    print("Type: \(kind)")
    print("Total Count: \(speedTestSummary.totalCount)")
    
    print("====== Details ======")
    
    print(speedTestSummary.details.renderTextTable())
    
    print("======= Statistics =======")
    print("Min: \(speedTestSummary.min.round(to: 2)) ms")
    print("Max: \(speedTestSummary.max.round(to: 2)) ms")
    print("Jitter: \(speedTestSummary.jitter.round(to: 2)) ms")
    print("Average: \(speedTestSummary.avg.round(to: 2)) ms")
    print("Medium: \(speedTestSummary.median.round(to: 2)) ms")
    print("Standard Deviation: \(speedTestSummary.stdDev.round(to: 2)) ms")
}
