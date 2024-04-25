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
#if canImport(Darwin)
import Darwin   // Apple platforms
#elseif canImport(Glibc)
import Glibc    // GlibC Linux platforms
#endif

internal func getAvailableInterfaces() throws -> [String: Set<String>] {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else {
        throw CLIError.failedToReadAvailableNetworkInterfaces(errno)
    }

    var res = [String: Set<String>]()

    guard let first = ifaddr else {
        print("no interfaces available")
        return res
    }

    for ifaddr in sequence(first: first, next: {$0.pointee.ifa_next}) {
        guard let addr = ifaddr.pointee.ifa_addr else {
            continue
        }

        if (Int32(ifaddr.pointee.ifa_flags) & IFF_LOOPBACK) != 0 ||
            (Int32(ifaddr.pointee.ifa_flags) & IFF_UP) == 0 {
            // skip loopback and inactive interfaces
            continue
        }

#if canImport(Darwin) // macOS
        let isKnownFamilyType = addr.pointee.sa_family == UInt8(AF_INET) ||
                                        addr.pointee.sa_family == UInt8(AF_INET6) ||
                                        addr.pointee.sa_family == UInt8(AF_LINK)
#else // Linux
        let isKnownFamilyType = addr.pointee.sa_family == UInt8(AF_INET) ||
                                addr.pointee.sa_family == UInt8(AF_INET6) ||
                                addr.pointee.sa_family == UInt8(AF_PACKET)
#endif

        if isKnownFamilyType {
            var cHostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let ret = getnameinfo(
                                addr,
                                socklen_t(addr.pointee.sa_len),
                                &cHostName,
                                socklen_t(cHostName.count),
                                nil,
                                0,
                                NI_NUMERICHOST
                            )
            if ret == 0 {
                let addrName = String(cString: ifaddr.pointee.ifa_name)
                let hostName = String(cString: cHostName)
                if !res.keys.contains(addrName) {
                    res[addrName] = Set()
                }
                if !hostName.isEmpty {
                    res[addrName]?.insert(hostName)
                }
            }
        }
    }

    freeifaddrs(ifaddr)
    return res
}
