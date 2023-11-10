//
//  ProtocolType.swift
//  
//
//  Created by JOHN ZZN on 11/7/23.
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
