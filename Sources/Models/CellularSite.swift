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
import SwiftyTextTable

struct CellularSite: Decodable, Identifiable {
    var id: String { name }

    let address: String
    let cellId: [String]
    let latitude: Double
    let longitude: Double
    let name: String
    let status: SiteStatus

}

extension CellularSite {
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case latitude = "latitude"
        case longitude = "longitude"
        case status = "status"
        case address = "address"
        case cellId = "cell_id"
    }
}

extension CellularSite {
    enum SiteStatus: String, Decodable {
        case active = "active"
        case confirmed = "confirmed"
        case inConversation = "in-conversation"
        case unknown = "unknown"
    }
}

extension CellularSite: Equatable {

}

extension CellularSite: CustomStringConvertible {
    var description: String {
        return "\(self.name): \(self.address)"
    }
}

extension CellularSite: TextTableRepresentable {
    public static var columnHeaders: [String] {
        return ["Name", "Latitude", "Longitude", "Status", "Address"]
    }

    public var tableValues: [CustomStringConvertible] {
        return [
            self.name,
            self.latitude,
            self.longitude,
            self.status.rawValue,
            self.address
        ]
    }
}
