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

internal func printSummary(_ pingSummary: PingSummary, for type: LCLPing.PingConfiguration.PingType, formats: Set<OutputFormat>) {
    for format in formats {
        switch format {
            case .json:
            printSummaryInJSON(pingSummary: pingSummary)
            case .yaml:
            printSummaryInYAML(pingSummary: pingSummary)
            case .default:
            printSummaryDefault(pingSummary: pingSummary, type: type)
        }
    }
}

internal func printSummaryInJSON(pingSummary: PingSummary) {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    guard let result = try? jsonEncoder.encode(pingSummary) else {
        print("PingSummary is corrupted and unable to output in JSON format.")
        return
    }

    print(String(data: result, encoding: .utf8)!)
}

internal func printSummaryInYAML(pingSummary: PingSummary) {
    let yamlEncoder = YAMLEncoder()
    yamlEncoder.options = .init(sortKeys: true)
    guard let result = try? yamlEncoder.encode(pingSummary) else {
        print("PingSummary is corrupted and unable to output in YAML format.")
        return
    }
    print(result)
}

internal func printSummaryDefault(pingSummary: PingSummary, type: LCLPing.PingConfiguration.PingType) {
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
