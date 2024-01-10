//
//  PingResult+Extension.swift
//  
//
//  Created by JOHN ZZN on 1/9/24.
//

import Foundation
import LCLPing
import SwiftyTextTable

extension PingResult: TextTableRepresentable {
    public static var columnHeaders: [String] {
        return ["Sequence #", "Latency(ms)", "Timestamp"]
    }
    
    public var tableValues: [CustomStringConvertible] {
        return ["#\(seqNum)", matchLatencyWithColor(latency), Date.toDateString(timeInterval: timestamp)]
    }
}
