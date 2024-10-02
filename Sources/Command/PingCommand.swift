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
        static var configuration: CommandConfiguration = CommandConfiguration(
            commandName: "ping",
            abstract: "Run Ping Latency and Reachability Test.",
            subcommands: [ICMPCommand.self, HTTPCommand.self]
        )
    }
}

extension LCLCLI {
    struct ICMPCommand: ParsableCommand {
        @Option(name: .shortAndLong, help: "The host that the ping request will be sent to.")
        var host: String

        @Option(name: .shortAndLong, help: "The port on the host to connec to, ranging from 0 to 65535")
        var port: Int?

        @Option(name: .shortAndLong, help: "Specify the number of times LCLPing runs the test. The number has to be greater than 0. Default is 10.")
        var count: UInt64?

        @Option(name: .shortAndLong, help: "The wait time, in milliseconds, between sending consecutive packet. Default is 1000 ms.")
        var interval: UInt64?

        @Option(name: .long, help: "Time-to-live for outgoing packets. The number has to be greater than 0. Default is 64. This option applies to ICMP only.")
        var ttl: UInt8?

        @Option(name: .long, help: "Time, in milliseconds, to wait for a reply for each packet sent. Default is 1000 ms.")
        var timeout: UInt64?

        @Flag(help: "Export the Ping result in JSON format.")
        var json: Bool = false

        @Flag(help: "Export the Ping result in YAML format.")
        var yaml: Bool = false

        static var configuration: CommandConfiguration = CommandConfiguration(
            commandName: "icmp",
            abstract: "Run ICMP Ping Latency and Reachability Test."
        )

        func run() throws {
            do {
                var config = try ICMPPingClient.Configuration(endpoint: .ipv4(host, port ?? 0))
                if let count = count {
                    config.count = Int(count)
                }
                if let interval = interval {
                    config.interval = .milliseconds(Int64(interval))
                }
                if let ttl = ttl {
                    config.timeToLive = ttl
                }
                if let timeout = timeout {
                    config.timeout = .milliseconds(Int64(timeout))
                }

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

                let client = ICMPPingClient(configuration: config)

                signal(SIGINT, SIG_IGN)
                // handle ctrl-c signal
                let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)

                stopSignal.setEventHandler {
                    print("Exit from ICMP Ping Test.")
                    client.cancel()
                    return
                }
                stopSignal.resume()

                let summary = try client.start().wait()
                generatePingSummary(summary, for: .icmp, formats: outputFormats)
                stopSignal.cancel()
            } catch {
                print("Error: \(error)")
            }
        }
    }

    struct HTTPCommand: ParsableCommand {

        @Option(name: .shortAndLong, help: "The URL that the HTTP request will be sent to.")
        var url: String

        @Option(name: .shortAndLong, help: "Specify the number of times the ping test runs. The number has to be greater than 0. Default is 10.")
        var count: UInt64?

        @Option(name: .long, help: "Time, in milliseconds, that the HTTP client will wait when connecting to the host. Default is 5000 ms.")
        var connectionTimeout: UInt64?

        @Option(name: .long, help: "Time, in milliseconds, HTTP will wait for the response from the host. Default is 1000 ms.")
        var readTimeout: UInt64?

        @Option(name: .long, help: "HTTP Headers to be included in the request. Use comma to separate <Key>:<Value>.")
        var headers: String?

        @Flag(name: .long, help: "Use Server-Timing in HTTP header to calculate latency. Server should support Server-Timing in HTTP response. Otherwise, a default 15ms will be taken into consideration.")
        var useServerTiming: Bool = false

        @Flag(help: "Use URLSession on Apple platform for underlying networking and measurement. This flag has no effect on Linux platform.")
        var useURLSession: Bool = false

        @Option(name: .long, help: "Specify the device name to which the data will be sent.")
        var deviceName: String?

        @Flag(help: "Export the Ping result in JSON format.")
        var json: Bool = false

        @Flag(help: "Export the Ping result in YAML format.")
        var yaml: Bool = false

        static var configuration: CommandConfiguration = CommandConfiguration(
            commandName: "http",
            abstract: "Run ICMP Ping Latency and Reachability Test."
        )

        func run() throws {
            var config = try HTTPPingClient.Configuration(url: url, deviceName: deviceName)
            if let count = count {
                config.count = Int(count)
            }

            if let connectionTimeout = connectionTimeout {
                config.connectionTimeout = .milliseconds(Int64(connectionTimeout))
            }
            if let readTimeout = readTimeout {
                config.readTimeout = .milliseconds(Int64(readTimeout))
            }

            if let headers = headers {
                var httpHeaders = [String: String]()
                headers.split(separator: ",").forEach { element in
                    let pair = element.split(separator: ":")
                    if pair.count == 2 {
                        httpHeaders.updateValue(String(pair[1]), forKey: String(pair[0]))
                    }
                }
                config.headers = httpHeaders
            }

            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            config.useURLSession = useURLSession
            #endif

            config.useServerTiming = useServerTiming

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

            let client = HTTPPingClient(configuration: config)

            signal(SIGINT, SIG_IGN)

            // handle ctrl-c signal
            let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)

            stopSignal.setEventHandler {
                print("Exit from ICMP Ping Test.")
                client.cancel()
                return
            }

            stopSignal.resume()

            let summary = try client.start().wait()
            generatePingSummary(summary, for: .http, formats: outputFormats)
            stopSignal.cancel()
        }
    }
}

extension LCLPing.PingType: ExpressibleByArgument {
    public init?(argument: String) {
        switch argument {
        case "icmp":
            self = .icmp
        case "http":
            self = .http
        default:
            self = .icmp
        }
    }
}
