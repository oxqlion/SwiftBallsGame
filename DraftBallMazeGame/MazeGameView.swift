//
//  MazeGameView.swift
//  DraftBallMazeGame
//
//  Created by Rafi Abhista  on 10/07/25.
//

import SwiftUI
import RealityKit

struct MazeGameView: View {
    @StateObject var motionManager = BallMotionManager()

    var body: some View {
        RealityView { content in
            let mazeGen = MazeGenerator(width: 5, height: 5)
            let floor = createFloor()
            content.add(floor)

            for row in mazeGen.grid {
                for cell in row {
                    content.add(createWalls(for: cell))
                }
            }

            let ball = createBall()
            content.add(ball)

            // Track force and apply to ball
            Task {
                while true {
                    try? await Task.sleep(nanoseconds: 20_000_000) // 0.02s
                    ball.addForce(motionManager.forceVector, relativeTo: nil)
                }
            }

        }
        .ignoresSafeArea()
    }

    func createFloor() -> Entity {
        let floor = ModelEntity(
            mesh: .generatePlane(width: 5, depth: 5),
            materials: [SimpleMaterial(color: .gray, isMetallic: false)]
        )
        floor.components.set(PhysicsBodyComponent(mode: .static))
        floor.components.set(CollisionComponent(shapes: [.generateBox(size: [5, 0.01, 5])]))
        return floor
    }

    func createBall() -> ModelEntity {
        let ball = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
        )
        ball.components.set(PhysicsBodyComponent(mode: .dynamic))
        ball.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)]))
        ball.position = SIMD3<Float>(0.5, 0.1, 0.5)
        return ball
    }

    func createWalls(for cell: MazeCell) -> Entity {
        let parent = Entity()

        let wallThickness: Float = 0.05
        let wallHeight: Float = 0.3
        let cellSize: Float = 1.0
        let x = Float(cell.x)
        let z = Float(cell.y)

        func wall(xOffset: Float, zOffset: Float) -> ModelEntity {
            let wall = ModelEntity(
                mesh: .generateBox(size: [cellSize, wallHeight, wallThickness]),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            wall.components.set(PhysicsBodyComponent(mode: .static))
            wall.components.set(CollisionComponent(shapes: [.generateBox(size: [cellSize, wallHeight, wallThickness])]))
            wall.position = SIMD3<Float>(x + xOffset, wallHeight / 2, z + zOffset)
            return wall
        }

        if cell.walls.contains(.top) {
            parent.addChild(wall(xOffset: 0.0, zOffset: -0.5))
        }
        if cell.walls.contains(.right) {
            let w = wall(xOffset: 0.5, zOffset: 0.0)
            w.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            parent.addChild(w)
        }
        if cell.walls.contains(.bottom) {
            parent.addChild(wall(xOffset: 0.0, zOffset: 0.5))
        }
        if cell.walls.contains(.left) {
            let w = wall(xOffset: -0.5, zOffset: 0.0)
            w.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            parent.addChild(w)
        }

        return parent
    }
}
