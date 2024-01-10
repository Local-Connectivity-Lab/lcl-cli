//
//  Color.swift
//  
//
//  Created by JOHN ZZN on 11/6/23.
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
