//
//  CLI+Date.swift
//  
//
//  Created by JOHN ZZN on 11/7/23.
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
}
