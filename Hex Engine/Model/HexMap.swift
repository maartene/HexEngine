//
//  HexMap.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

class HexMap {
    
    private static let cubeDirections = [
        CubeCoord(x: +1, y: -1, z: 0), CubeCoord(x: +1, y: 0, z: -1), CubeCoord(x: 0, y: +1, z: -1),
        CubeCoord(x: -1, y: +1, z: 0), CubeCoord(x: -1, y: 0, z: +1), CubeCoord(x: 0, y: -1, z: +1)]
    
    private static let axialDirections = [
        AxialCoord(q: +1, r: 0), AxialCoord(q: +1, r: -1), AxialCoord(q: 0, r: -1),
        AxialCoord(q: -1, r: 0), AxialCoord(q: -1, r: +1), AxialCoord(q: 0, r: +1)]
    
    private static let cubeDiagonals = [
        CubeCoord(x: +2, y: -1, z: -1), CubeCoord(x: +1, y: +1, z: -2), CubeCoord(x: -1, y: +2, z: -1),
        CubeCoord(x: -2, y: +1, z: +1),CubeCoord(x: -1, y: -1, z: +2),CubeCoord(x: +1, y: -2, z: +1)]
    
    let width: Int
    let height: Int
    
    private var tiles: [Tile]
    
    init(width: Int, height: Int) {
        self.width = width;
        self.height = height;
        
        tiles = [Tile].init(repeating: .void, count: width * height)
    }
    
    func indexIsValid(q: Int, r: Int) -> Bool {
        return q >= 0 && q < width && r >= 0 && r < height
    }
    
    subscript(q: Int, r: Int) -> Tile {
        get {
            if indexIsValid(q: q, r: r) {
                return tiles[(r * width) + q]
            } else {
                return .void
            }
        }
        set {
            if indexIsValid(q: q, r: r) {
                tiles[(r * width) + q] = newValue
            } else {
                // out of bounds, do nothing
            }
        }
    }
    
    subscript(tile: CubeCoord) -> Tile {
        get {
            let tileAxial = tile.toAxial()
            return self[tileAxial.q, tileAxial.r]
        }
        set {
            let tileAxial = tile.toAxial()
            self[tileAxial.q, tileAxial.r] = newValue
        }
    }
    
    subscript(tile: AxialCoord) -> Tile {
        get {
            return self[tile.q, tile.r]
        }
        set {
            self[tile.q, tile.r] = newValue
        }
    }
    
    // Neighbours
    static func cubeDirection(directionIndex: Int) -> CubeCoord {
        guard directionIndex >= 0 && directionIndex < cubeDirections.count else {
            fatalError("directionIndex needs to be between 0 and \(cubeDirections.count - 1)")
        }
        
        return cubeDirections[directionIndex]
    }
    
    static func cubeNeighbourCoord(tile: CubeCoord, directionIndex: Int) -> CubeCoord {
        return tile + cubeDirection(directionIndex: directionIndex)
    }
    
    static func axialNeighours(directionIndex: Int) -> AxialCoord {
        guard directionIndex >= 0 && directionIndex < axialDirections.count else {
            fatalError("directionIndex needs to be between 0 and \(axialDirections.count - 1)")
        }
        
        return axialDirections[directionIndex]
    }
    
    static func axialNeighbourCoord(tile: AxialCoord, directionIndex: Int) -> AxialCoord {
        return tile + axialNeighours(directionIndex: directionIndex)
    }
    
    // Diagonals
    static func cubeDiagonal(directionIndex: Int) -> CubeCoord {
        guard directionIndex >= 0 && directionIndex < cubeDiagonals.count else {
            fatalError("directionIndex needs to be between 0 and \(cubeDiagonals.count - 1)")
        }
        
        return cubeDiagonals[directionIndex]
    }
    
    static func cubeDiagonalNeighbour(tile: CubeCoord, directionIndex: Int) -> CubeCoord {
        return tile + cubeDiagonal(directionIndex: directionIndex)
    }
    
    static func distance(from tileA: CubeCoord, to tileB: CubeCoord) -> Int {
        return max(abs(tileA.x - tileB.x), abs(tileA.y - tileB.y), abs(tileA.z - tileA.z))
    }
    
    static func distance(from tileA: AxialCoord, to tileB: AxialCoord) -> Int {
        let ac = tileA.toCube()
        let bc = tileB.toCube()
        return distance(from: ac, to: bc)
    }
    
    // Line drawing
    static func lerp(a: Double, b: Double, t: Double) -> Double {
        return a + (b - a) * t
    }
    
    static func cubeCoordLerp(tileA: CubeCoord, tileB: CubeCoord, t: Double) -> (x: Double, y: Double, z: Double) {
        return (x: lerp(a: Double(tileA.x), b: Double(tileB.x), t: t),
                y: lerp(a: Double(tileA.y), b: Double(tileB.y), t: t),
                z: lerp(a: Double(tileA.z), b: Double(tileB.z), t: t))
    }
    
    static func cubeDrawLine(from tileA: CubeCoord, to tileB: CubeCoord) -> [CubeCoord] {
        let N = distance(from: tileA, to: tileB)
        var results = [CubeCoord]()
        for i in 0 ..< N {
            let fractCube = cubeCoordLerp(tileA: tileA, tileB: tileB, t: 1.0 / Double(N) * Double(i))
            results.append(CubeCoord.roundToCubeCoord(fractX: fractCube.x, fractY: fractCube.y, fractZ: fractCube.z))
        }
        return results
    }
    
    // Movement
    static func coordinatesWithinRange(from tile: CubeCoord, range: Int) -> [CubeCoord] {
        var results = [CubeCoord]()
        for x in -range ... range {
            let minY = max(-range, -x - range)
            let maxY = min(+range, -x + range)
            for y in minY ... maxY {
                let z = -x - y
                results.append(tile + CubeCoord(x: x, y: y, z: z))
            }
        }
        return results
    }
    
    static func coordinatesIntersectingRanges(from tileA: CubeCoord, withRange rangeTileA: Int, to TileB: CubeCoord, withRange rangeTileB: Int) -> [CubeCoord] {
        let coordinatesInRangeOfTileA = coordinatesWithinRange(from: tileA, range: rangeTileA)
        let coordinatesInRangeOfTileB = coordinatesWithinRange(from: TileB, range: rangeTileB)
        
        return coordinatesInRangeOfTileA.filter {
            coordinatesInRangeOfTileB.contains($0)
        }
    }
    
    func reachableFromTile(_ startTile: CubeCoord, movement: Int) -> [CubeCoord] {
        var visited = Set<CubeCoord>()
        visited.insert(startTile)
        var fringes = [Set<CubeCoord>]()
        fringes.append(visited)
        
        for k in 2 ... movement {
            fringes.append(Set<CubeCoord>())
            for hex in fringes[k - 1] {
                for dir in 0 ..< 6 {
                    let neighbourCube = HexMap.cubeNeighbourCoord(tile: hex, directionIndex: dir)
                    let neighbourHexCoord = neighbourCube.toAxial()
                    let tile = self[neighbourHexCoord.q, neighbourHexCoord.r]
                    if visited.contains(neighbourCube) == false && tile.blocksMovement == false {
                        visited.insert(neighbourCube)
                        fringes[k].insert(neighbourCube)
                    }
                }
            }
        }
        return Array(visited)
    }
}

struct CubeCoord: Equatable, Hashable {
    let x, y, z: Int
    
    static func +(lhs: CubeCoord, rhs: CubeCoord) -> CubeCoord {
        return CubeCoord(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func roundToCubeCoord(fractX: Double, fractY: Double, fractZ: Double) -> CubeCoord {
        var x = Int(round(fractX))
        var y = Int(round(fractY))
        var z = Int(round(fractZ))
        
        let xDiff = abs(Double(x) - fractX)
        let yDiff = abs(Double(y) - fractY)
        let zDiff = abs(Double(z) - fractZ)
        
        if xDiff > yDiff && xDiff > zDiff {
            x = -y - z
        } else if yDiff > zDiff {
            y = -x - z
        } else {
            z = -x - y
        }
        
        return CubeCoord(x: x, y: y, z: z)
    }
    
    func toAxial() -> AxialCoord {
        let q = self.x
        let r = self.z
        return AxialCoord(q: q, r: r)
    }
}

struct AxialCoord: Equatable {
    let q, r: Int
    
    static func +(lhs: AxialCoord, rhs: AxialCoord) -> AxialCoord {
        return AxialCoord(q: lhs.q + rhs.q, r: lhs.r + rhs.r)
    }
    
    func toCube() -> CubeCoord {
        let x = self.q
        let z = self.r
        let y = -x - z
        return CubeCoord(x: x, y: y, z: z)
    }
}

enum Tile: Int {
    case void
    case Water
    case Sand
    case Grass
    case Forest
    case Mountain
    
    var blocksMovement: Bool {
        switch self {
        case .Mountain:
            return true
        case .Water:
            return true
        case .void:
            return true
        default:
            return false
        }
    }
}
