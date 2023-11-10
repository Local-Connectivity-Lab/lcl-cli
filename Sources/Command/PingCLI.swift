// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import LCLPing
import Foundation
import Dispatch

#if canImport(Darwin)
import Darwin   // Apple platforms
#elseif canImport(Glibc)
import Glibc    // GlibC Linux platforms
#endif


@main
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
    
    @OptionGroup
    var httpConfiguration: HTTPOptionCommand
    
    @Flag(help: "Include extra information in the output.")
    var verbose: Bool = false
    
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    @Flag(help: "Use URLSession for underlying networking and measurement. If type is set to icmp, then this flag has no effect.")
    var useNative: Bool = false
    #endif
    
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "lclping",
        abstract: "A command-line tool from Local Connectivity Lab @UWCSE",
        subcommands: [
            HTTPOptionCommand.self
        ]
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
                httpConfig.useServerTiming = httpConfiguration.useServerTiming
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
        
        var config = LCLPing.Configuration()
        config.verbose = verbose
        config.useNative = useNative

        do {
            signal(SIGINT, SIG_IGN)
            
            var ping = LCLPing(configuration: config)
            
            // handle ctrl-c signal
            let stopSignal = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
            
            stopSignal.setEventHandler {
                print("Exit!!!!!!!!")
                ping.stop()
                return
            }
            
            stopSignal.resume()
            
            try await ping.start(pingConfiguration: pingConfig)
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

    private func printSummary(_ pingSummary: PingSummary, for type: LCLPing.PingConfiguration.PingType) {
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
