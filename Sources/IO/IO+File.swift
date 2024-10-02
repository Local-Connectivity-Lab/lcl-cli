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

// File IO needs to handle
// read file
// write to file
class FileIO {

    static let `default`: FileIO = .init()

    let fileManager = FileManager.default

    private init() {

    }

    var home: URL {
        self.fileManager.homeDirectoryForCurrentUser
    }

    func loadFrom(_ url: URL) throws -> Data? {
        return self.fileManager.contents(atPath: url.relativePath)
    }

    func fileExists(_ url: URL) -> Bool {
        return self.fileManager.fileExists(atPath: url.relativePath)
    }

    func createIfAbsent(at name: URL, isDirectory: Bool) throws {
        if isDirectory {
            try self.fileManager.createDirectory(atPath: name.relativePath, withIntermediateDirectories: true)
        } else {
            // file
            self.fileManager.createFile(atPath: name.relativePath, contents: nil)
        }
    }

    func attributesOf(_ fileURL: URL) throws -> [FileAttributeKey: Any] {
        if self.fileExists(fileURL) {
            return try self.fileManager.attributesOfItem(atPath: fileURL.relativePath)
        }

        return [FileAttributeKey.size: 0]
    }

    func write(data: Data, to fileURL: URL) throws {
        try FileHandle(forWritingTo: fileURL).write(contentsOf: data)
    }

    func remove(at fileURL: URL) throws {
        if fileExists(fileURL) {
            try self.fileManager.removeItem(atPath: fileURL.relativePath)
        }
    }
}
