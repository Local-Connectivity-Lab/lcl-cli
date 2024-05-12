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

import ArgumentParser
import LCLPing
import Foundation
import Dispatch
import LCLAuth

extension LCLCLI {
    struct PingCommand: AsyncParsableCommand {
        @Option(name: .shortAndLong, help: "The ping mechanism, i.e. icmp or http.")
        var type: String

        @Option(name: .shortAndLong, help: "The host that the ping request will be sent to.")
        var host: String

        @Option(name: .shortAndLong, help: "The port on the host to connec to, ranging from 0 to 65535")
        var port: UInt16?

        @Option(name: .shortAndLong, help: "Specify the number of times LCLPing runs the test. The number has to be greater than 0. Default is 10.")
        var count: UInt16?

        @Option(name: .shortAndLong, help: "The wait time, in second, between sending consecutive packet. Default is 1 second.")
        var interval: TimeInterval?

        @Option(name: .long, help: "Time-to-live for outgoing packets. The number has to be greater than 0. Default is 64.")
        var ttl: UInt16?

        @Option(name: .long, help: "Time, in second, to wait for a reply for each packet sent. Default is 1 second.")
        var timeout: TimeInterval?

        @Flag(name: .long, help: "Use Server-Timing in HTTP header to calculate latency. Server should support Server-Timing in HTTP response.")
        var useServerTiming: Bool = false

        @Option(name: .shortAndLong, help: "The path to the file where SCN credential is stored to report test metrics to SCN server.")
        var upload: String?

        @Flag(help: "Include extra information in the output.")
        var verbose: Bool = false

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        @Flag(help: "Use URLSession on Apple platform for underlying networking and measurement. If type is set to icmp, then this flag has no effect.")
        var useURLSession: Bool = false
#endif

        @Flag(help: "Export the Ping result in JSON format.")
        var json: Bool = false

        @Flag(help: "Export the Ping result in YAML format.")
        var yaml: Bool = false

        static var configuration: CommandConfiguration = CommandConfiguration(
            commandName: "ping",
            abstract: "Run Ping Reachability Test."
        )

        func validate() throws {
            if !["icmp", "http"].contains(type) {
                throw CLIError.invalidPingType
            }
        }

        func run() async throws {
            let pingType: LCLPing.PingConfiguration.PingType
            switch type {
            case "icmp":
                pingType = .icmp
            case "http":
                var httpConfig = LCLPing.PingConfiguration.HTTPOptions()
                httpConfig.useServerTiming = useServerTiming
                pingType = .http(httpConfig)
            default:
                fatalError("Unknown type \(type). Must be either 'icmp' or 'http'.")
            }

            let endpoint = LCLPing.PingConfiguration.IP.ipv4(host, port == nil ? nil : port!)

            var pingConfigStorage = LCLPing.PingConfiguration(type: pingType, endpoint: endpoint)
            if let count = count {
                pingConfigStorage.count = count
            }

            if let interval = interval {
                pingConfigStorage.interval = interval
            }

            if let ttl = ttl {
                pingConfigStorage.timeToLive = UInt16(ttl)
            }

            if let timeout = timeout {
                pingConfigStorage.timeout = timeout
            }

            let pingConfig = pingConfigStorage

            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let options = LCLPing.Options(verbose: verbose, useNative: useURLSession)
            #else
            let options = LCLPing.Options(verbose: verbose)
            #endif

            do {
                signal(SIGINT, SIG_IGN)

                var ping = LCLPing(options: options)

                // handle ctrl-c signal
                let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)

                stopSignal.setEventHandler {
                    print("Exit from Ping Test")
                    ping.stop()
                    return
                }

                stopSignal.resume()

                try await ping.start(pingConfiguration: pingConfig)
                switch ping.status {
                case .error, .ready, .running:
                    print("LCLPing encountered some error while running tests")
                case .stopped, .finished:
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

                    generatePingSummary(ping.summary, for: pingType, formats: outputFormats)

                    // TODO: read credential and optionally write the data to file
                    // 1. check if credential is provided
                    // 2. If not, skip reporting
                    // 3. If yes, check if corresponding keys have been generated (in .lcl folder in the user's home directory)
                    // 4. If not, generate the keys by calling method in the Auth module. Then save the data to the .lcl folder
                    // 5. If yes, read the keys file and verify against the provided credential to see if data is corrupted
                    // 6. If all checks pass, use the credential to upload the data to the backend server

                    //                if let credentialDirectory = upload {
                    //
                    //                    if !FileIO.default.fileExists(file: "\(FileIO.default.home)/.lcl/data") {
                    //                        print("Please use --register to register your credential with SCN first.")
                    //                        return
                    //                    }
                    //
                    //                    let credential = try FileIO.default.loadFrom(fileName: credentialDirectory)
                    //                    let registeredData = try FileIO.default.readLines(fileName: "\(FileIO.default.home)/.lcl/data")
                    //                    if (registeredData.count != 4) {
                    //                        print("Invalid registration data. Please contact SCN administrator or re-register.")
                    //                        return
                    //                    }
                    //                    let R = registeredData[0]
                    //                    let hPKR = registeredData[1]
                    //                    let skT = registeredData[2]
                    //                    let privateKey = try ECDSA.deserializePrivateKey(raw: skT)
                    //                    let publicKey = ECDSA.derivePublicKey(from: privateKey)
                    //                    let signature = registeredData[3]
                    //
                    //                    if (ECDSA.verify(message: , signature: signature, publicKey: publicKey)) {
                    //
                    //                    }
                    //
                    //
                    //
                    //
                    //
                    //
                    //                    // TODO: stop and alert user to use --register first before proceed
                    //
                    //
                    //                }
                }
            } catch {
                print("LCLPing encountered some error while running tests: \(error)")
            }
        }
    }
}
