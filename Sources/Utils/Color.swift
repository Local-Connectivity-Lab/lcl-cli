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
import ANSITerminal

func matchLatencyWithColor(_ latency: Double) -> String {
    let latencyString = "\(latency.round(to: 2))"
    switch latency {
    case 0..<200:
        return latencyString.asGreen
    case 200..<500:
        return latencyString.asYellow
    default:
        return latencyString.asRed
    }
}
