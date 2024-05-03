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
import LCLSpeedTest

class SpeedTest {
    private let testType: TestType
    private var uploadResults: [MeasurementProgress]
    private var downloadResults: [MeasurementProgress]
    private var testClient: SpeedTestClient

    struct TestResult {
        let upload: [MeasurementProgress]
        let download: [MeasurementProgress]
    }

    init(testType: TestType) {
        self.testType = testType
        self.uploadResults = []
        self.downloadResults = []
        self.testClient = SpeedTestClient()
    }

    func run() async throws -> TestResult {
        self.testClient.onDownloadProgress = { measurement in
            self.downloadResults.append(measurement)
        }
        self.testClient.onUploadProgress = { measurement in
            self.uploadResults.append(measurement)
        }
        try await testClient.start(with: self.testType)
        return TestResult(upload: self.uploadResults, download: self.downloadResults)
    }

    func stop() {
        do {
            try testClient.cancel()
        } catch {
            fatalError("Speed test stopped with error: \(error)")
        }
    }
}
