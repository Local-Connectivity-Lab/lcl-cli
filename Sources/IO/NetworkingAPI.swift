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
#if os(Linux)
import FoundationNetworking
#endif

struct NetworkingAPI {

    private static var BASE_URL: String = "https://coverage.seattlecommunitynetwork.org/api"
    private static var MEDIA_TYPE: String = "application/json"

    static func send(to urlString: String, using payload: Data) async throws -> Result<Void, CLIError> {
        guard let url = URL(string: urlString) else {
            throw CLIError.invalidURL(urlString)
        }

        do {
            _ = try await send(to: url, using: payload)
            return .success(())
        } catch {
            return .failure(error as! CLIError)
        }
    }

    static func send(to url: URL, using payload: Data) async throws -> Data? {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(MEDIA_TYPE, forHTTPHeaderField: "Content-Type")
        request.allowsCellularAccess = true

        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.uploadTask(with: request, from: payload) { data, response, error in
                if error != nil {
                    continuation.resume(with: .failure(CLIError.uploadError))
                }

                let statusCode = (response as! HTTPURLResponse).statusCode
                switch statusCode {
                case (200...299):
                    continuation.resume(with: .success(data))
                case (400...499):
                    continuation.resume(with: .failure(CLIError.clientError(statusCode)))
                case (500...599):
                    continuation.resume(with: .failure(CLIError.serverError(statusCode)))
                default:
                    continuation.resume(with: .failure(CLIError.uploadError))
                }
            }
        }
    }
}

extension NetworkingAPI {
    enum Endpoint: String {
        case register = "/register"
        case report = "/report_measurement"

        var url: String {
            return NetworkingAPI.BASE_URL + self.rawValue
        }
    }
}
