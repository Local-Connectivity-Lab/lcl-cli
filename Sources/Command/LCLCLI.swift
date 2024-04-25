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

import ArgumentParser
import LCLPing
import Foundation
import Dispatch
import LCLPingAuth

#if canImport(Darwin)
import Darwin   // Apple platforms
#elseif canImport(Glibc)
import Glibc    // GlibC Linux platforms
#endif

@main
struct LCLCLI: AsyncParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "lclping",
        abstract: "A command-line tool from Local Connectivity Lab @UWCSE",
        subcommands: [
            RegisterCommand.self,
            PingCommand.self,
            SpeedTestCommand.self,
            MeasureCommand.self,
            NetworkInterfaceCommand.self
        ],
        defaultSubcommand: PingCommand.self
    )
}
