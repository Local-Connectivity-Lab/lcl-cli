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

enum ProtocolType: CInt {
    case v4 = 2
    case v6 = 10
    case unix = 1
    
    var string: String {
        switch self {
        case.unix:
            return "Unix Domain Socket"
        case .v4:
            return "IPv4"
        case .v6:
            return "IPv6"
        }
    }
}
