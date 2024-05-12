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

struct NetworkInterfaceCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "interfaces",
        abstract: "List available network interfaces on the machine."
    )

    func run() async throws {
        let availableInterfaces = try getAvailableInterfaces().sorted { $0.key < $1.key }
        for interface in availableInterfaces {
            let sortedHostNames = interface.value.sorted()
            let interfaceName = interface.key
            print("\(interfaceName)      \(sortedHostNames)")
        }
    }
}
