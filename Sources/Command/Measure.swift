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
import LCLPing
import LCLAuth
import Crypto

extension LCLCLI {
    struct MeasureCommand: AsyncParsableCommand {

        @Option(name: .shortAndLong, help: "Show datapoint on SCN's public visualization. Your contribution will help others better understand our coverage.")
        var showData: Bool = false

        static let configuration = CommandConfiguration(
            commandName: "measure",
            abstract: "Run SCN test suite and optionally report the measurement result to SCN."
        )

        func run() async throws {
            let encoder: JSONEncoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys

            // TODO: prompted picker if the location option is not set
            var sites: [CellularSite]
            let result: Result<[CellularSite]?, CLIError> = await NetworkingAPI.get(from: NetworkingAPI.Endpoint.site.url)
            switch result {
            case .failure(let error):
                throw error
            case .success(let cs):
                if let s = cs {
                    sites = s
                } else {
                    throw CLIError.failedToLoadContent("No cellular site is available. Please check your internet connection or talk to the SCN administrator.")
                }

            }
            var picker = Picker<CellularSite>(title: "Choose the cellular site you are currently at.", options: sites)

            let homeURL = FileIO.default.home.appendingPathComponent(".lcl")
            let skURL = homeURL.appendingPathComponent("sk")
            let sigURL = homeURL.appendingPathComponent("sig")
            let rURL = homeURL.appendingPathComponent("r")
            let hpkrURL = homeURL.appendingPathComponent("hpkr")
            let keyURL = homeURL.appendingPathComponent("key")
            let keyData = try loadData(keyURL)

            let symmetricKeyRecovered = SymmetricKey(data: keyData)

            let skDataEncrypted = try loadData(skURL)
            let skData = try decrypt(cipher: skDataEncrypted, key: symmetricKeyRecovered)
            let sigDataEncrypted = try loadData(sigURL)
            let sigData = try decrypt(cipher: sigDataEncrypted, key: symmetricKeyRecovered)
            let rDataEncrypted = try loadData(rURL)
            let rData = try decrypt(cipher: rDataEncrypted, key: symmetricKeyRecovered)
            let hpkrDataEncrypted = try loadData(hpkrURL)
            let hpkrData = try decrypt(cipher: hpkrDataEncrypted, key: symmetricKeyRecovered)
            let validationResultJSON = try encoder.encode(ValidationResult(R: rData, skT: skData, hPKR: hpkrData))

            let ecPrivateKey = try ECDSA.deserializePrivateKey(raw: skData)

            guard try ECDSA.verify(message: validationResultJSON, signature: sigData, publicKey: ecPrivateKey.publicKey) else {
                throw CLIError.contentCorrupted
            }

            let pingConfig = try ICMPPingClient.Configuration(endpoint: .ipv4("google.com", 0))
            let outputFormats: Set<OutputFormat> = [.default]

            let client = ICMPPingClient(configuration: pingConfig)
            let speedTest = SpeedTest(testType: .downloadAndUpload)

            signal(SIGINT, SIG_IGN)
            let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
            stopSignal.setEventHandler {
                print("Exit from SCN Measurement Test")
                client.cancel()
                speedTest.stop()
                return
            }

            stopSignal.resume()

            guard let selectedSite = picker.pick() else {
                throw CLIError.noCellularSiteSelected
            }

            let deviceId = UUID().uuidString

            let summary = try await client.start().get()

            let speedTestResults = try await speedTest.run()
            let downloadSummary = prepareSpeedTestSummary(data: speedTestResults.download, unit: .Mbps)
            let uploadSummary = prepareSpeedTestSummary(data: speedTestResults.upload, unit: .Mbps)

            generatePingSummary(summary, for: .icmp, formats: outputFormats)
            generateSpeedTestSummary(downloadSummary, kind: .download, formats: outputFormats, unit: .Mbps)
            generateSpeedTestSummary(uploadSummary, kind: .upload, formats: outputFormats, unit: .Mbps)

            // MARK: Upload test results to the server
            encoder.outputFormatting = .prettyPrinted
            do {
                let report = ConnectivityReportModel(
                    cellId: selectedSite.cellId.first!,
                    deviceId: deviceId,
                    downloadSpeed: downloadSummary.avg,
                    uploadSpeed: uploadSummary.avg,
                    latitude: selectedSite.latitude,
                    longitude: selectedSite.longitude,
                    packetLoss: Double(summary.timeout.count) / Double(summary.totalCount),
                    ping: summary.avg,
                    timestamp: Date.getCurrentTime(),
                    jitter: summary.jitter
                )
                let serialized = try encoder.encode(report)
                let sig_m = try ECDSA.sign(message: serialized, privateKey: ECDSA.deserializePrivateKey(raw: skData))
                let measurementReport = MeasurementReportModel(sigmaM: sig_m.hex, hPKR: hpkrData.hex, M: serialized.hex, showData: showData)

                let reportToSent = try encoder.encode(measurementReport)
                let result = await NetworkingAPI.send(to: NetworkingAPI.Endpoint.report.url, using: reportToSent)
                switch result {
                case .success:
                    print("Data reported successfully.")
                case .failure(let error):
                    print("Data report failed with error: \(error)")
                }
            } catch EncodingError.invalidValue {
                print("Measurement data is corruptted.")
            } catch let error as LCLAuthError {
                print("Registration info is corruptted. \(error)")
            } catch {
                print("Data report failed with error: \(error)")
            }
        }

        private func loadData(_ from: URL) throws -> Data {
            guard let data = try FileIO.default.loadFrom(from) else {
                throw CLIError.contentCorrupted
            }
            return data
        }
    }
}
