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
import NIOCore

internal func getAvailableInterfaces() throws -> [String: Set<String>] {
    var res = [String: Set<String>]()
    
    for device in try System.enumerateDevices() {
        let name = device.name
        if !res.keys.contains(name) {
            res[name] = Set()
        }
        guard let addr = device.address?.ipAddress else {
            continue
        }
        res[name]?.insert(addr)
    }
    
    return res
}
