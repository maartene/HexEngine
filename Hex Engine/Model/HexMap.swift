//
//  HexMap.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

struct HexMap {
    
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
    
    var tileDidChangedEventHandlers = [(tile: AxialCoord, oldValue: Tile?, newValue: Tile) -> Void]()
    
    // pathfinding stuff
    var pathfindingGraph = GKGraph()
    var nodeToTileCoordMap = [GKGraphNode: AxialCoord]()
    var tileCoordToNodeMap = [AxialCoord : GKGraphNode]()
    
    private var tiles = [AxialCoord: Tile]()
    
    init(width: Int, height: Int) {
        self.width = width;
        self.height = height;
        
        
        let halfR = height / 2
        let halfQ = (width / 2)
        
        for r in -halfR ... halfR {
            
            for q in (-halfQ - (Double(r) / 2.0).roundToZero()) ... (halfQ - (Double(r) / 2.0).roundToZero()) {
                    self[q, r] = .void
            }
        }
    }
    
    func indexIsValid(q: Int, r: Int) -> Bool {
        return tiles[AxialCoord(q: q, r: r)] != nil
    }
    
    subscript(tile: AxialCoord) -> Tile {
        get {
            if indexIsValid(q: tile.q, r: tile.r) {
                return tiles[tile] ?? .void
            } else {
                return .void
            }
        }
        set {
            let oldValue = tiles[tile]
            tiles[tile] = newValue
            // print("Tile \(tile) changed value from \(oldValue ?? Tile.void) to \(newValue)")
            
            tileDidChangedEventHandlers.forEach {
                $0(tile, oldValue, newValue)
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
    
    subscript(q: Int, r: Int) -> Tile {
        get {
            return self[AxialCoord(q: q, r: r)]
        }
        set {
            self[AxialCoord(q: q, r: r)] = newValue
        }
    }
    
    func getTileCoordinates() -> [AxialCoord] {
        return Array<AxialCoord>(tiles.keys)
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
    
    static func getAxialNeighbourCoordinates(tile: AxialCoord) -> [AxialCoord] {
        var result = [AxialCoord]()
        for dir in 0 ..< axialDirections.count {
            result.append(axialNeighbourCoord(tile: tile, directionIndex: dir))
        }
        return result
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
    
    // GameplayKit Pathfinding
    
    // we use this function to rebuild the pathfinding graph. this is required for instance
    // when terrain changes. 
    mutating func rebuildPathFindingGraph() {
        // start by clearing out the old pathfinding data
        pathfindingGraph.nodes?.forEach {
            $0.removeConnections(to: $0.connectedNodes, bidirectional: false)
        }
        pathfindingGraph = GKGraph()
        
        // transform between nodes and tiles using dictionaries
        // mapping between nodes and coordinates needs to be set up only once
        if tileCoordToNodeMap.count == 0 || nodeToTileCoordMap.count == 0 {
            tileCoordToNodeMap.removeAll()
            nodeToTileCoordMap.removeAll()
            
            tiles.forEach {
                let node = HexGraphNode(costToEnter: $0.value.costToEnter)
                tileCoordToNodeMap[$0.key] = node
                nodeToTileCoordMap[node] = $0.key
            }
        }
    
        nodeToTileCoordMap.forEach {
            let node = $0.key
            let coord = $0.value
            
            let neighbours = HexMap.getAxialNeighbourCoordinates(tile: coord)
            
            neighbours.forEach {
                if self[$0].blocksMovement == false {
                    node.addConnections(to: [tileCoordToNodeMap[$0]!], bidirectional: false)
                }
            }
        }
        
        pathfindingGraph.add(Array(nodeToTileCoordMap.keys))
    }
    
    func findPathFrom(_ tile1: AxialCoord, to tile2: AxialCoord) -> [AxialCoord]? {
        if let node1 = tileCoordToNodeMap[tile1], let node2 = tileCoordToNodeMap[tile2] {
            let nodePath = pathfindingGraph.findPath(from: node1, to: node2)
            
            var result = [AxialCoord]()
            var cost = 0.0
            nodePath.forEach {
                let coord = nodeToTileCoordMap[$0]!
                cost += self[coord].costToEnter
                result.append(coord)
            }
            print("calculated path from \(tile1) to \(tile2). Total path cost: \(cost).")
            return result
        } else {
            return nil
        }
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

struct AxialCoord: Equatable, Hashable, CustomStringConvertible {
    var description: String {
        return "(q: \(q),r: \(r))"
    }
    
    let q, r: Int
    
    static func +(lhs: AxialCoord, rhs: AxialCoord) -> AxialCoord {
        return AxialCoord(q: lhs.q + rhs.q, r: lhs.r + rhs.r)
    }
    
    static var zero: AxialCoord {
        get {
            return AxialCoord(q: 0, r: 0)
        }
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
        return costToEnter < 0
    }
    
    var costToEnter: Double {
        switch self {
        case .Grass:
            return 1.0
        case .Sand:
            return 1.0
        case .Forest:
            return 1.5
        default:
            return -1
        }
    }
}

class HexGraphNode: GKGraphNode {
    let cost: Double
    
    init(costToEnter: Double = 1.0) {
        cost = costToEnter
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func cost(to node: GKGraphNode) -> Float {
        return Float(cost)
    }
}
