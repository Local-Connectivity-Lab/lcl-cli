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

/// The network measurement unit used by the speed test framework
enum NDT7MeasurementUnit: String, CaseIterable, Identifiable, Encodable {
    
    case Mbps
    case MBps
    
    var id: Self {self}
    
    var toString: String {
        switch (self) {
        case .Mbps:
            return "mbps"
        case .MBps:
            return "MB/s"
        }
    }
}

extension NDT7Measurement {
    
    /// A boolean value indicating whether there is some non-empty data return from the test server
    var hasValue: Bool {
        return appInfo?.elapsedTime != nil && appInfo?.numBytes != nil
    }
    
    /// data in Mbps
    var defaultValueInMegaBits: Double {
        get {
            self.convertTo(unit: .Mbps)
        }
    }
    
    /// data in MB/s
    var defaultValueInMegaBytes: Double {
        get {
            self.convertTo(unit: .MBps)
        }
    }
    
    /**
     Convert the measurement data to the given unit
     
     - Parameters:
        unit: the target unit to convert to
     - Returns: the value in `Double` under the specified unit measurement
     */
    func convertTo(unit: NDT7MeasurementUnit) -> Double {
        if let elapsedTime = appInfo?.elapsedTime, let numBytes = appInfo?.numBytes {
            let time = Float64(elapsedTime) / 1000000
            var speed = Float64(numBytes) / time
            switch (unit) {
            case .Mbps:
                speed *= 8
            case .MBps:
                speed *= 1
            }
            
            speed /= 1000000
            return speed
        }
        
        return .zero
    }
    
    /// empty measurement report from the test server
    public static var empty: NDT7Measurement {
        .init(tcpInfo: nil)
    }
    
}
