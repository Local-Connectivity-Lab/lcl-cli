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

struct Networking {
    
    private static var BASE_URL: String = "https://coverage.seattlecommunitynetwork.org/api"
    private static var MEDIA_TYPE: String = "application/json"
    
    static func send(to urlString: String, using payload: Data) async throws -> Result<Void, CLIError> {
        guard let url = URL(string: urlString) else {
            throw CLIError.invalidURL(urlString)
        }
        
        return await send(to: url, using: payload)
    }
    
    static func send(to url: URL, using payload: Data) async -> Result<Void, CLIError> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(MEDIA_TYPE, forHTTPHeaderField: "Content-Type")
        request.allowsCellularAccess = true

        
        do {
            let resp: (Data, URLResponse) = try await URLSession.shared.upload(for: request, from: payload)
            
            let statusCode =  (resp.1 as! HTTPURLResponse).statusCode

            switch statusCode {
            case (200...299):
                return .success(())
            case (400...499):
                return .failure(.clientError(statusCode))
            case (500...599):
                return .failure(.serverError(statusCode))
            default:
                return .failure(.uploadError)
            }
        } catch  {
            return .failure(.uploadError)
        }
    }
}

extension Networking {
    enum Endpoint: String {
        case register = "/register"
        case report = "/report_measurement"
        
        var url: String {
            return Networking.BASE_URL + self.rawValue
        }
    }
}
