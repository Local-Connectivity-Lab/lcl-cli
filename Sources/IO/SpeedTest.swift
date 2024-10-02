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
import LCLSpeedtest

class SpeedTest {
    private let testType: TestType
    private var uploadSpeed: [MeasurementProgress]
    private var downloadSpeed: [MeasurementProgress]
    private var uploadTCPMeasurement: [TCPInfo]
    private var downloadTCPMeasurement: [TCPInfo]

    private var testClient: SpeedTestClient

    struct TestResult {
        let uploadSpeed: [MeasurementProgress]
        let downloadSpeed: [MeasurementProgress]
        let uploadTCPMeasurement: [TCPInfo]
        let downloadTCPMeasurement: [TCPInfo]
    }

    init(testType: TestType) {
        self.testType = testType
        self.uploadSpeed = []
        self.downloadSpeed = []
        self.uploadTCPMeasurement = []
        self.downloadTCPMeasurement = []
        self.testClient = SpeedTestClient()
    }

    func run(deviceName: String? = nil) async throws -> TestResult {
        self.testClient.onDownloadProgress = { progress in
            self.downloadSpeed.append(progress)
        }
        self.testClient.onDownloadMeasurement = { measurement in
            guard let tcpInfo = measurement.tcpInfo else {
                return
            }
            self.downloadTCPMeasurement.append(tcpInfo)
        }
        self.testClient.onUploadProgress = { progress in
            self.uploadSpeed.append(progress)
        }
        self.testClient.onUploadMeasurement = { measurement in
            guard let tcpInfo = measurement.tcpInfo else {
                return
            }
            self.downloadTCPMeasurement.append(tcpInfo)
        }
        try await testClient.start(with: self.testType, deviceName: deviceName)
        return TestResult(
            uploadSpeed: self.uploadSpeed,
            downloadSpeed: self.downloadSpeed,
            uploadTCPMeasurement: self.uploadTCPMeasurement,
            downloadTCPMeasurement: self.downloadTCPMeasurement
        )
    }

    func stop() {
        do {
            try testClient.cancel()
        } catch {
            fatalError("Speed test stopped with error: \(error)")
        }
    }
}
