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

/// Network test result data container
struct ConnectivityReportModel: Encodable {
    private var cellId: String
    private var deviceId: String
    private var downloadSpeed: Double
    private var uploadSpeed: Double
    private var latitude: Double
    private var longitude: Double
    private var packetLoss: Double
    private var ping: Double
    private var timestamp: String
    private var jitter: Double

    init(
        cellId: String,
        deviceId: String,
        downloadSpeed: Double,
        uploadSpeed: Double,
        latitude: Double,
        longitude: Double,
        packetLoss: Double,
        ping: Double,
        timestamp: String,
        jitter: Double
    ) {
        self.cellId = cellId
        self.deviceId = deviceId
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
        self.latitude = latitude
        self.longitude = longitude
        self.packetLoss = packetLoss
        self.ping = ping
        self.timestamp = timestamp
        self.jitter = jitter
    }
}

extension ConnectivityReportModel {
    enum CodingKeys: String, CodingKey {
        case cellId = "cell_id"
        case deviceId = "device_id"
        case latitude = "latitude"
        case longitude = "longitude"
        case timestamp = "timestamp"
        case uploadSpeed = "upload_speed"
        case downloadSpeed = "download_speed"
        case ping = "ping"
        case packetLoss = "package_loss"
    }
}