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
import ArgumentParser
import LCLPingAuth


extension PingCLI {
    struct Register: AsyncParsableCommand {
        
        @Option(name: .shortAndLong, help: "Path to the SCN credential file given by the SCN administrator.")
        var filePath: String
        
        static let configuration = CommandConfiguration(abstract: "Register with SCN server to report test data.")
        
        func run() async throws {
            guard let credentialData = try FileIO.default.loadFrom(fileName: filePath) else {
                print("Fail to read content from \(filePath). Exit.")
                return
            }

            try FileIO.default.createIfAbsent(name: "\(FileIO.default.home)/.lcl", isDirectory: true)
            
            try FileIO.default.createIfAbsent(name: "\(FileIO.default.home)/.lcl/data", isDirectory: false)
            let attributes = try FileIO.default.attributesOf(name: "\(FileIO.default.home)/.lcl/data")
            var shouldOverwrite: Bool = false
            if (attributes[FileAttributeKey.size] as? Int) != 0 {
                // file is NOT empty
                var response: String?
                while true {
                    print("You've already have data associated with SCN. Do you want to overwrite it? [y\\N]")
                    response = readLine()?.lowercased()
                    switch response {
                    case "yes":
                        shouldOverwrite = true
                        break
                    case "n":
                        shouldOverwrite = false
                        break
                    default:
                        ()
                    }
                }
            }
            
            if !shouldOverwrite {
                print("Registration cancelled.")
                return
            }

            let validationResult = try LCLPingAuth.validate(credential: credentialData)
            var outputData = Data()
            outputData.append(validationResult.skT)
            let sk_t = try ECDSA.deserializePrivateKey(raw: validationResult.skT)
            let pk_t = ECDSA.derivePublicKey(from: sk_t)
            outputData.append(pk_t.derRepresentation)
            let h_sec = digest(data: outputData, algorithm: .SHA256)
            outputData.removeAll()
            outputData.append(validationResult.hPKR)
            outputData.append(h_sec)
            let h_concat = Data(outputData)
            let sigma_r = try ECDSA.sign(message: h_concat, privateKey: sk_t)
            let registration = RegistrationModel(sigmaR: sigma_r.hex, h: h_concat.hex, R: validationResult.R.hex)
            let registrationJson = try JSONEncoder().encode(registration)
            switch try await Networking.send(to: Networking.Endpoint.register.url, using: registrationJson) {
            case .success():
                print("Registration complete!")
            case .failure(let error):
                print("Registration failed: \(error)")
                return
            }
            
            let validationJson = try JSONEncoder().encode(validationResult)
            let privateKey = try ECDSA.deserializePrivateKey(raw: validationResult.skT)
            let signature = try ECDSA.sign(message: validationJson, privateKey: privateKey)
            try FileIO.default.write(data: [validationResult.R, validationResult.hPKR, validationResult.skT, signature], fileName: "\(FileIO.default.home)/.lcl/data")
        }
    }

}
