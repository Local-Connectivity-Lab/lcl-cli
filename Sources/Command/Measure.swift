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
import LCLPingAuth

extension LCLCLI {
    struct MeasureCommand: AsyncParsableCommand {

        // TODO: need to list all available interfaces
        // TODO: need to ask user to select the interface on which the test will be run

        @Option(name: .shortAndLong, help: "Path to the SCN credential to report the measurement result to SCN")
        var filePath: String?

        @Option(name: .shortAndLong, help: "Show datapoint on SCN's public visualization. Your contribution will help others better understand our coverage.")
        var showData: Bool = false

        static let configuration = CommandConfiguration(commandName: "measure", abstract: "Run SCN test suite and optionally report the measurement result to SCN.")

        // private func exitWithError(_ message: String) {
        //     print(message)
        // }

        func run() async throws {
            let shouldUpload: Bool = filePath == nil
            var preferences: [Data]?
            if let filePath = filePath {
                if shouldUpload {
                    do {
                        preferences = try FileIO.default.readLines(fileName: filePath)
                        precondition(preferences?.count == 4, "Registration data doesn't match the record.")
                        let preferencesSignature = preferences?[3]
                        // TODO: veirfy signature
                        // ECDSA.verify(message: Data, signature: Data, publicKey: K1.ECDSA.PublicKey)
                    } catch {
                        // exitWithError("Registration data at \(filePath) is corrupted or doesn't exist. Please check the path you provided is correct, or contact the administrator.")
                    }
                }
            }

            let pingOptions = LCLPing.Options()
            let pingConfig = LCLPing.PingConfiguration(type: .icmp, endpoint: .ipv4("google.com", 0))
            let outputFormats: Set<OutputFormat> = [.default]

            var ping = LCLPing(options: pingOptions)
            let speedTest = SpeedTest(testType: .downloadAndUpload)

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
            generateSpeedTestSummary(downloadSummary, kind: .download, formats: outputFormats, unit: .Mbps)
            generateSpeedTestSummary(uploadSummary, kind: .upload, formats: outputFormats, unit: .Mbps)

            // MARK: Upload test results to the server
            // if shouldUpload, let preferences = preferences {
            //     let encoder = JSONEncoder()
            //     encoder.outputFormatting = .prettyPrinted
            //     do {
            //         let serialized = try encoder.encode(report)
            //         let sig_m = try ECDSA.sign(message: serialized, privateKey: ECDSA.deserializePrivateKey(raw: preferences[2]))
            //         let measurementReport = MeasurementReportModel(sigmaM: sig_m.hex, hPKR: preferences[1].hex, M: serialized.hex, showData: showData)

            //         let reportToSent = try encoder.encode(measurementReport)
            //         let result = NetworkingAPI.send(to: NetworkingAPI.Endpoint.report.url, using: reportToSent)
            //         switch result {
            //         case .success:
            //             print("Data reported successfully.")
            //         case .failure(let error):
            //             print("Data report failed with error: \(error)")
            //         }
            //     } catch EncodingError.invalidValue {
            //         print("Measurement data is corruptted.")
            //     } catch let error as LCLPingAuthError {
            //         print("Registration info is corruptted.")
            //     } catch {
            //         print("Data report failed with error: \(error)")
            //     }
            // }
        }
    }
}
