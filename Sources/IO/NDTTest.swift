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

class NDTTest: NDT7TestInteraction {
    
    typealias NDTResult = (NDT7TestConstants.Kind, NDT7Measurement)
    private var ndtTest: NDT7Test?
    private var ndtContinuation: AsyncThrowingStream<NDTResult, Error>.Continuation?
    
    
    public func start() -> AsyncThrowingStream<NDTResult, Error> {
        self.ndtTest = NDT7Test(settings: NDT7Settings())
        self.ndtTest?.delegate = self
        
        return AsyncThrowingStream { continuation in
            self.ndtContinuation = continuation
            self.ndtTest?.startTest(download: true, upload: true) { [weak self] error in
                guard self != nil else {return}
                if let error = error {
                    continuation.finish(throwing: error)
                } else {
                    continuation.finish()
                }
            }
        }
    }
    
    public func cancel() {
        self.ndtTest?.cancel()
        self.ndtTest?.cleanup()
        self.ndtContinuation?.finish()
    }
    
    func test(kind: NDT7TestConstants.Kind, running: Bool) {
        print("Speed test \(kind) is \(running ? "running" : "finished")")
    }
    
    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        ndtContinuation?.yield((kind, measurement))
    }
    
    func error(kind: NDT7TestConstants.Kind, error: NSError) {
        print("Error occurred while running speed test: \(error)")
        ndtContinuation?.finish(throwing: error)
    }
    
}
