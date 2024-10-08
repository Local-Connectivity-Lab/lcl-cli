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
import ArgumentParser
import LCLAuth
import Crypto

extension LCLCLI {
    struct RegisterCommand: AsyncParsableCommand {

        @Option(name: .shortAndLong, help: "Path to the SCN credential file given by the SCN administrator.")
        var filePath: String

        static let configuration = CommandConfiguration(commandName: "register",
                                                        abstract: "Register with SCN server to report test data.")

        func run() async throws {
            guard let filePathURL = URL(string: filePath), let credentialCode = try FileIO.default.loadFrom(filePathURL) else {
                throw CLIError.failedToReadFile("Fail to read content from path '\(filePath)'. Exit.")
            }
            
            let homeURL = FileIO.default.home.appendingPathComponent(Constants.cliDirectory)
            let skURL = homeURL.appendingPathComponent("sk")
            let sigURL = homeURL.appendingPathComponent("sig")
            let rURL = homeURL.appendingPathComponent("r")
            let hpkrURL = homeURL.appendingPathComponent("hpkr")
            let keyURL = homeURL.appendingPathComponent("key")

            try FileIO.default.createIfAbsent(at: homeURL, isDirectory: true)

            if FileIO.default.fileExists(skURL) ||
                FileIO.default.fileExists(sigURL) ||
                FileIO.default.fileExists(rURL) ||
                FileIO.default.fileExists(hpkrURL) ||
                FileIO.default.fileExists(keyURL) {
                // file is NOT empty
                var response: String?
                while true {
                    print("You've already have data associated with SCN. Do you want to overwrite it? [yes\\N]")
                    response = readLine()?.lowercased()
                    var shouldExit = false
                    switch response {
                    case "yes":
                        try FileIO.default.remove(at: skURL)
                        try FileIO.default.remove(at: hpkrURL)
                        try FileIO.default.remove(at: rURL)
                        try FileIO.default.remove(at: sigURL)

                        shouldExit = true
                    case "n":
                        print("Registration cancelled.")
                        return
                    default:
                        ()
                    }

                    if shouldExit {
                        break
                    }
                }
            }

            let encoder: JSONEncoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let validationResult = try LCLAuth.validate(credential: credentialCode)
            var outputData = Data()
            outputData.append(validationResult.skT)
            let sk_t = try ECDSA.deserializePrivateKey(raw: validationResult.skT)
            let pk_t = ECDSA.derivePublicKey(from: sk_t)
            outputData.append(pk_t.derRepresentation)
            var h_sec = digest(data: outputData, algorithm: .SHA256)
            outputData.removeAll()
            outputData.append(validationResult.hPKR)
            outputData.append(h_sec)
            var h_concat = Data(outputData)
            var sigma_r = try ECDSA.sign(message: h_concat, privateKey: sk_t)
            let registration = RegistrationModel(sigmaR: sigma_r.hex, h: h_concat.hex, R: validationResult.R.hex)
            var registrationJson = try encoder.encode(registration)
            switch await NetworkingAPI.send(to: NetworkingAPI.Endpoint.register.url, using: registrationJson) {
            case .success:
                print("Registration complete!")
            case .failure(let error):
                throw CLIError.failedToRegister(error)
            }

            let validationJson = try encoder.encode(validationResult)
            let privateKey = try ECDSA.deserializePrivateKey(raw: validationResult.skT)
            let signature = try ECDSA.sign(message: validationJson, privateKey: privateKey)
            
            try FileIO.default.write(data: validationResult.R, to: rURL)
            try FileIO.default.write(data: validationResult.hPKR, to: hpkrURL)
            try FileIO.default.write(data: validationResult.skT, to: skURL)
            try FileIO.default.write(data: signature, to: sigURL)
            
            // cleanup
            outputData.removeAll()
            h_concat.removeAll()
            sigma_r.removeAll()
            h_sec.removeAll()
            registrationJson.removeAll()
        }
    }
}
