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

extension LCLCLI {
    struct CelluarSiteCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "cellular-sites",
            abstract: "Get info on SCN cellular sites"
        )
        func run() async throws {
            let result: Result<[CellularSite]?, CLIError> = await NetworkingAPI
                                                                .get(from: NetworkingAPI.Endpoint.site.url)
            switch result {
            case .failure(let error):
                throw error
            case .success(let sites):
                if let sites = sites {
                    print(sites.renderTextTable())
                } else {
                    print("No sites available")
                }
            }
        }
    }
}
