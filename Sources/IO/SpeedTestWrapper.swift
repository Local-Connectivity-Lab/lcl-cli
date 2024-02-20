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

class SpeedTest {
    private var uploadResults: [NDT7Measurement]
    private var downloadResults: [NDT7Measurement]
    
    private lazy var speedTest: NDTTest = NDTTest()
    
    init() {
        self.uploadResults = []
        self.downloadResults = []
    }
    
    func run() async throws -> (upload: [NDT7Measurement], download: [NDT7Measurement]) {
        for try await res in speedTest.start() {
            let (kind, measurement) = res

            if !measurement.hasValue { continue }

            await MainActor.run {
                switch kind {
                case .download:
                    downloadResults.append(measurement)
                case .upload:
                    uploadResults.append(measurement)
                }
            }
        }
        
        return (upload: uploadResults, download: downloadResults)
    }
    
    func stop() {
        speedTest.cancel()
    }
}
