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

extension Date {
    static func toDateString(timeInterval: TimeInterval, timeZone: TimeZone? = nil) -> String {
        let formatter = DateFormatter()
        if let timeZone = timeZone {
            formatter.timeZone = timeZone
        }
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"

        let date = Date(timeIntervalSince1970: timeInterval)
        return formatter.string(from: date)
    }

    /**
     Get the current time in ISO8601 format in String
     - Returns: the current time in the current time zone in ISO8601 format in String
     */
    static func getCurrentTime() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        return formatter.string(from: .init())
    }
}
