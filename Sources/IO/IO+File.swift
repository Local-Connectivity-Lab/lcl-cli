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

    func readLines(from url: URL) throws -> [Data] {
        let fd = try FileHandle(forReadingFrom: url)
        var results = [Data]()
        let newline = UInt8(ascii: "\n")
        var buffer = Data()
        var startIndex = 0

        while true {
            let temp = fd.readData(ofLength: 1024)
            if temp.isEmpty { break } // EOF

            buffer.append(temp)

            var currentIndex = startIndex
            // INV: buffer[startIndex : currentIndex - 1] contains all the data before new line character
            while currentIndex != buffer.count {
                if buffer[currentIndex] == newline {
                    // Process the line from startIndex to currentIndex
                    let lineData = buffer[startIndex..<currentIndex]
                    if !lineData.isEmpty {
                        results.append(lineData)
                    }
                    startIndex = currentIndex + 1
                }
                currentIndex += 1
            }

            // Remove processed data from buffer up to the last startIndex
            if startIndex > 0 {
                buffer.removeSubrange(0..<startIndex)
                currentIndex -= startIndex
                startIndex = 0
            }
        }

        try fd.close()
        return results
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
        try data.write(to: fileURL, options: [.atomic])
    }

    func remove(at fileURL: URL) throws {
        if fileExists(fileURL) {
            try self.fileManager.removeItem(atPath: fileURL.relativePath)
        }
    }
}
