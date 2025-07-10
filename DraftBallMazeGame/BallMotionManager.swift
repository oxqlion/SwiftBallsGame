//
//  BallMotionManager.swift
//  DraftBallMazeGame
//
//  Created by Rafi Abhista  on 10/07/25.
//

import CoreMotion
import simd

class BallMotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var forceVector = SIMD3<Float>(0, 0, 0)

    init() {
        motionManager.deviceMotionUpdateInterval = 0.02
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let gravity = motion?.gravity else { return }
            let fx = Float(gravity.x) * 10
            let fz = Float(gravity.y) * 10
            self.forceVector = SIMD3<Float>(fx, 0, fz)
        }
    }
}
