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
import ArgumentParser
import LCLSpeedtest

extension LCLCLI {
    struct SpeedTestCommand: AsyncParsableCommand {

        @Option(name: .shortAndLong, help: "Specify the unit (MBps or mbps) for the speed test results. Default is \"mbps\"")
        var unit: String = "mbps"

        @Option(name: .shortAndLong, help: "Specify the direction of the test. A test can be of three types: download, upload or downloadAndUpload")
        var type: TestType

        @Option(name: .long, help: "Specify the device name to which the data will be sent.")
        var deviceName: String?

        @Flag(help: "Export the Speed Test result in JSON format.")
        var json: Bool = false

        static let configuration = CommandConfiguration(commandName: "speedtest", abstract: "Run speedtest using the NDT test infrastructure.")

        func run() async throws {
            let speedTestUnit: MeasurementUnit
            switch unit {
            case "mbps":
                speedTestUnit = .Mbps
            case "MBps":
                speedTestUnit = .MBps
            default:
                speedTestUnit = .Mbps
            }

            let speedTest = SpeedTest(testType: type)

            signal(SIGINT, SIG_IGN)
            let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
            stopSignal.setEventHandler {
                print("Exit from Speedtest")
                speedTest.stop()
                return
            }

            stopSignal.resume()

            let speedTestResults = try await speedTest.run(deviceName: deviceName)

            let downloadSummary = prepareSpeedTestSummary(data: speedTestResults.downloadSpeed, tcpInfos: speedTestResults.downloadTCPMeasurement, for: .download, unit: speedTestUnit)
            let uploadSummary = prepareSpeedTestSummary(data: speedTestResults.uploadSpeed, tcpInfos: speedTestResults.uploadTCPMeasurement, for: .upload, unit: speedTestUnit)

            var outputFormats: Set<OutputFormat> = []
            if json {
                outputFormats.insert(.json)
            }

            if outputFormats.isEmpty {
                outputFormats.insert(.default)
            }

            switch type {
            case .download:
                generateSpeedTestSummary(downloadSummary, kind: .download, formats: outputFormats, unit: speedTestUnit)
            case .upload:
                generateSpeedTestSummary(uploadSummary, kind: .upload, formats: outputFormats, unit: speedTestUnit)
            case .downloadAndUpload:
                generateSpeedTestSummary(downloadSummary, kind: .download, formats: outputFormats, unit: speedTestUnit)
                generateSpeedTestSummary(uploadSummary, kind: .upload, formats: outputFormats, unit: speedTestUnit)
            }
        }
    }
}

extension TestType: ExpressibleByArgument {
    public init?(argument: String) {
        self = TestType(rawValue: argument) ?? .download
    }
}
