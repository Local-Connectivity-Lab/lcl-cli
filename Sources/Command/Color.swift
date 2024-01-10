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
import LCLPing

enum Colors: String {
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case `default` = "\u{001B}[0;0m"
}

func matchLatencyWithColor(_ latency: Double) -> String {
    let color: Colors
    switch latency {
    case 0..<200:
        color = .green
    case 200..<500:
        color = .yellow
    default:
        color = .red
    }
    
    return color + "\(latency.round(to: 2))" + .default
}

func + (left: Colors, right: String) -> String {
    return left.rawValue + right
}

func + (left: String, right: Colors) -> String {
    return left + right.rawValue
}
