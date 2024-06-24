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

enum CLIError: Error {
    case failedToReadFile(String)
    case requestRedirected(Int)
    case clientError(Int)
    case serverError(Int)
    case uploadError(Error?)
    case fetchError(Error?)
    case invalidURL(String)
    case failedToReadAvailableNetworkInterfaces(Int32)
    case failedToOpenSocket(Int32)
    case decodingError
    case failedToRegister(Error)
    case contentCorrupted
    case failedToLoadContent(String)
    case noCellularSiteSelected
}

extension CLIError: CustomStringConvertible {
    var description: String {
        switch self {
        case .failedToReadFile(let string):
            return string
        case .requestRedirected(let int):
            return "Request is redirected. Code (\(int))"
        case .clientError(let int):
            return "HTTP Client Error. Code (\(int))"
        case .serverError(let int):
            return "HTTP Server Error. Code (\(int))"
        case .uploadError(let error):
            return "Failed to upload to SCN server: \(String(describing: error))"
        case .fetchError(let error):
            return "Cannot fetch from SCN server: \(String(describing: error))"
        case .invalidURL(let string):
            return "URL(\(string)) is invalid."
        case .failedToReadAvailableNetworkInterfaces(let int32):
            return "Cannot read available interfaces from the system. Code (\(int32))"
        case .failedToOpenSocket(let int32):
            return "Cannot open socket. Code (\(int32))"
        case .decodingError:
            return "Cannot decode data."
        case .failedToRegister(let error):
            return "Cannot register your QRCode information with SCN. Please contact your SCN administrator. \(String(describing: error))"
        case .contentCorrupted:
            return "Content is corrupted."
        case .failedToLoadContent(let string):
            return "Cannot load content: \(string)"
        case .noCellularSiteSelected:
            return "No cellular site is selected."
        }
    }
}
