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
import ArgumentParser

extension LCLCLI {
    struct SpeedTestCommand: AsyncParsableCommand {
        
        @Option(name: .shortAndLong, help: "Specify the unit (MBps or mbps) for the speed test results. Default is \"mbps\"")
        var unit: String = "mbps"
        
        @Flag(help: "Export the Ping result in JSON format.")
        var json: Bool = false
        
        @Flag(help: "Export the Ping result in YAML format.")
        var yaml: Bool = false
        
        static let configuration = CommandConfiguration(commandName: "speedtest", abstract: "Run speedtest using the NDT test infrastructure.")
        
        
        func run() async throws {
            let speedTestUnit: NDT7MeasurementUnit
            switch unit {
            case "mbps":
                speedTestUnit = .Mbps
            case "MBps":
                speedTestUnit = .MBps
            default:
                speedTestUnit = .Mbps
            }
            
            
            let speedTest = SpeedTest()
            
            signal(SIGINT, SIG_IGN)
            let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
            stopSignal.setEventHandler {
                print("Exit from Speed Test")
                speedTest.stop()
                return
            }
            
            stopSignal.resume()
            
            let speedTestResults = try await speedTest.run()
            
            let downloadSummary = prepareSpeedTestSummary(data: speedTestResults.download, unit: speedTestUnit)
            let uploadSummary = prepareSpeedTestSummary(data: speedTestResults.upload, unit: speedTestUnit)
            
            var outputFormats: Set<OutputFormat> = []
            if json {
                outputFormats.insert(.json)
            }
            
            if yaml {
                outputFormats.insert(.yaml)
            }
            
            if outputFormats.isEmpty {
                outputFormats.insert(.default)
            }
            
            
            generateSpeedTestSummary(downloadSummary, kind: .download, formats: outputFormats)
            generateSpeedTestSummary(uploadSummary, kind: .upload, formats: outputFormats)
        }
    }
}
