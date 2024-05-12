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

/// The measurement report data model that will be used to report measurement data to the backend server
struct MeasurementReportModel: Encodable {
    private var sigmaM: String
    private var hPKR: String
    private var M: String
    private var showData: Bool

    init(sigmaM: String, hPKR: String, M: String, showData: Bool) {
        self.sigmaM = sigmaM
        self.hPKR = hPKR
        self.M = M
        self.showData = showData
    }
}

extension MeasurementReportModel {
    enum CodingKeys: String, CodingKey {
        case sigmaM = "sigma_m"
        case hPKR = "h_pkr"
        case M = "M"
        case showData = "show_data"
    }
}
