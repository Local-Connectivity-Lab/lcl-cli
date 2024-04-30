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

enum CLIError: Error {
    case invalidPingType
    case failedToReadFile(String)
    case requestRedirected(Int)
    case clientError(Int)
    case serverError(Int)
    case uploadError(Error?)
    case fetchError(Error?)
    case invalidURL(String)
    case failedToReadAvailableNetworkInterfaces(Int32)
    case failedToOpenSocket(Int32)
    case failedToGetDeviceControlInformation(Int32)
    case decodingError
    case fileReadError(String)
    case failedToRegister(Error)
    case contentCorrupted
    case failedToLoadContent(String)
}
