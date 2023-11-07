// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import LCLPing
import Foundation
import Dispatch


@main
struct PingCommand: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "The ping mechanism, i.e. icmp or http.")
    var type: String
    
    @Option(name: .shortAndLong, help: "The host that the ping request will be sent to.")
    var host: String
    
    @Option(name: .shortAndLong, help: "The port on the host to connec to")
    var port: Int?

    @Option(name: .shortAndLong, help: "Specify the number of times LCLPing runs the test.")
    var count: Int?
    
    @Option(name: .shortAndLong, help: "The wait time, in second, between sending consecutive packet")
    var interval: TimeInterval?
    
    @Option(name: .long, help: "Time-to-live for outgoing packets")
    var ttl: Int?
    
    @Option(name: .long, help: "Time, in second, to wait for a reply for each packet sent")
    var timeout: TimeInterval?
    
    @OptionGroup
    var httpConfiguration: HTTPOptionCommand
    
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "lclping",
        abstract: "A command-line tool from Local Connectivity Lab @UWCSE",
        subcommands: [
            HTTPOptionCommand.self
        ]
    )
    
    func run() async throws {
        let pingType: LCLPing.Configuration.PingType
        switch type {
            case "icmp":
                pingType = .icmp
            case "http":
                var httpConfig = LCLPing.Configuration.HTTPOptions()
                httpConfig.useServerTiming = httpConfiguration.useServerTiming
                pingType = .http(httpConfig)
            default:
                fatalError("Unknown type \(type). Must be either 'icmp' or 'http'.")
        }

        let endpoint = LCLPing.Configuration.IP.ipv4(host, port == nil ? nil : UInt16(port!))

        var pingConfig = LCLPing.Configuration(type: pingType, endpoint: endpoint)
        if let count = count {
            pingConfig.count = uint16(count)
        }

        if let interval = interval {
            pingConfig.interval = interval
        }

        if let ttl = ttl {
            pingConfig.timeToLive = UInt16(ttl)
        }

        if let timeout = timeout {
            pingConfig.timeout = timeout
        }

        let config = pingConfig

        do {
            var ping = LCLPing()
            try await ping.start(configuration: config)
            switch ping.status {
                case .error, .ready, .running:
                    print("LCLPing encountered some error while running tests")
                case .stopped, .finished:
                printSummary(ping.summary, for: pingType)
            }
        } catch {
            print("LCLPing encountered some error while running tests: \(error)")
        }
    }

    private func printSummary(_ pingSummary: PingSummary, for type: LCLPing.Configuration.PingType) {
        print("====== Ping Result ======")
        let protocolType = ProtocolType(rawValue: pingSummary.protocol)
        print("Host: \(pingSummary.ipAddress):\(pingSummary.port) [\(protocolType?.string ?? "Unknown Protocol")]")
        print("Total Count: \(pingSummary.totalCount)")
        
        print("====== Details ======")
        
        for detail in pingSummary.details {
            print(matchInterval(pingResult: detail, type: type))
        }
        
        print("Duplicate: \(pingSummary.duplicates.sorted())")
        print("Timeout: \(pingSummary.timeout.sorted())")
        
        print("======= Statistics =======")
        print("Min: \(pingSummary.min.round(to: 2)) ms")
        print("Max: \(pingSummary.max.round(to: 2)) ms")
        print("Jitter: \(pingSummary.jitter.round(to: 2)) ms")
        print("Average: \(pingSummary.avg.round(to: 2)) ms")
        print("Medium: \(pingSummary.median.round(to: 2)) ms")
        print("Standard Deviation: \(pingSummary.stdDev.round(to: 2)) ms")
    }
}


struct HTTPOptionCommand: ParsableCommand {
    @Flag(name: .long, help: "Use Server-Timing in HTTP header to calculate latency. Server should support Server-Timing in HTTP response.")
    var useServerTiming: Bool = false
    
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "http-option",
        abstract: "Configuration for Ping using HTTP"
    )
}
