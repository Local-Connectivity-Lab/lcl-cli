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
import LCLPing

extension LCLCLI {
    struct MeasureCommand: AsyncParsableCommand {
        
        @Option(name: .shortAndLong, help: "Path to the SCN credential to report the measurement result to SCN")
        var filePath: String?
        
        static let configuration = CommandConfiguration(commandName: "measure", abstract: "Run SCN test suite and optionally report the measurement result to SCN.")
        
        
        func run() async throws {
            
            let pingOptions = LCLPing.Options()
            let pingConfig = LCLPing.PingConfiguration(type: .icmp, endpoint: .ipv4("google.com", 0))
            let outputFormats: Set<OutputFormat> = [.default]

            var ping = LCLPing(options: pingOptions)
            let speedTest = SpeedTest()
            
            signal(SIGINT, SIG_IGN)
            let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
            stopSignal.setEventHandler {
                print("Exit from SCN Measurement Test")
                ping.stop()
                speedTest.stop()
                return
            }
            
            stopSignal.resume()
            
            var isPingComplete: Bool = false
            try await ping.start(pingConfiguration: pingConfig)
            switch ping.status {
            case .error, .ready, .running:
                print("Ping Test encountered some error while running tests")
            case .stopped, .finished:
                isPingComplete = true
            }
            
            let speedTestResults = try await speedTest.run()
            let downloadSummary = prepareSpeedTestSummary(data: speedTestResults.download, unit: .Mbps)
            let uploadSummary = prepareSpeedTestSummary(data: speedTestResults.upload, unit: .Mbps)
            if isPingComplete {
                generatePingSummary(ping.summary, for: .icmp, formats: outputFormats)
            }
            generateSpeedTestSummary(downloadSummary, kind: .download, formats: outputFormats)
            generateSpeedTestSummary(uploadSummary, kind: .upload, formats: outputFormats)   
        }
    }
}
