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

    func loadFrom(fileName file: String) throws -> Data? {
        return self.fileManager.contents(atPath: file)
    }

    func readLines(fileName file: String) throws -> [Data] {
        let url = URL(fileURLWithPath: file)
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

    func fileExists(file fileName: String) -> Bool {
        return self.fileManager.fileExists(atPath: fileName)
    }

    func createIfAbsent(name: String, isDirectory: Bool) throws {
        if isDirectory {
            try self.fileManager.createDirectory(atPath: name, withIntermediateDirectories: true)
        } else {
            // is file
            self.fileManager.createFile(atPath: name, contents: nil)
        }
    }

    func attributesOf(name fileName: String) throws -> [FileAttributeKey: Any] {
        try self.fileManager.attributesOfItem(atPath: fileName)
    }

    func write(data: Data, fileName file: String) throws {
        let url = URL(fileURLWithPath: file)
        try data.write(to: url, options: [.atomic])
    }

    func write(data: [Data], fileName file: String) throws {
        let url = URL(fileURLWithPath: file)
        let fd = try FileHandle(forWritingTo: url)
        for d in data {
            try fd.seekToEnd()
            try fd.write(contentsOf: d)
            try fd.write(contentsOf: "\n".data(using: .utf8)!)
        }

        try fd.close()
    }
}
