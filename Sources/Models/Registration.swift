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

/// The user registration data model for login
struct RegistrationModel: Codable {
    private var sigmaR: String
    private var h: String
    private var R: String

    init(sigmaR: String, h: String, R: String) {
        self.sigmaR = sigmaR
        self.h = h
        self.R = R
    }
}

extension RegistrationModel {
    enum CodingKeys: String, CodingKey {
        case sigmaR = "sigma_r"
        case h = "h"
        case R = "R"
    }
}
