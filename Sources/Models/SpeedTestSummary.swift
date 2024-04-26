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
import SwiftyTextTable

struct SpeedTestSummary: Encodable {
    public let min: Double
    public let max: Double
    public let avg: Double
    public let median: Double
    public let stdDev: Double
    public let jitter: Double
    public let details: [SpeedTestElement] // in mbps
    public let totalCount: Int
}

struct SpeedTestElement: Encodable, Comparable {
    static func < (lhs: SpeedTestElement, rhs: SpeedTestElement) -> Bool {
        return lhs.speed < rhs.speed
    }

    public let seqNum: Int
    public let speed: Double
    public let unit: MeasurementUnit
}

extension SpeedTestElement: TextTableRepresentable {
    public static var columnHeaders: [String] {
        return ["Sequence #", "Speed"]
    }

    public var tableValues: [CustomStringConvertible] {
        return ["\(seqNum)", "\(speed.convertTo(from: .Mbps, to: unit).round(to: 2)) \(unit.string)"]
    }
}
