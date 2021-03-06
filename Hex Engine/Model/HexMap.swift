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

struct HexMap: Codable {
    
    enum MapWrapType: Int, Codable {
        case none
        case horizontal
    }
    
    /*
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tiles, forKey: .tiles)
    }
    
    init(from decoder: Decoder) throws {
        let values = decoder.container(keyedBy: <#T##CodingKey.Protocol#>)
    }*/
    
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
    let wrapType: MapWrapType
    
    private var tiles = [AxialCoord: Tile]()
    
    func qOffsetFor(row: Int) -> Int {
        return (Double(row) / 2.0).roundToZero()
    }
    
    init(width: Int, height: Int, mapWrapType: MapWrapType = .none) {
        self.width = width;
        self.height = height;
        self.wrapType = mapWrapType
        
        let halfR = height / 2
        let halfQ = (width / 2)
        
        for r in -halfR ... halfR {
            
            for q in (-halfQ - qOffsetFor(row: r)) ... (halfQ - qOffsetFor(row: r)) {
                    self[q, r] = .void
            }
        }
    }
    
    func indexIsValid(q: Int, r: Int) -> Bool {
        return tiles[AxialCoord(q: q, r: r)] != nil
    }
    
    subscript(tile: AxialCoord) -> Tile {
        get {
            let wrappedCoord = toWrappedCoord(tile)
            return tiles[wrappedCoord, default: .void]
            /*if indexIsValid(q: tile.q, r: tile.r) {
                return tiles[tile] ?? .void
            } else {
                return .void
            }*/
        }
        set {
            //let oldValue = tiles[tile]
            tiles[tile] = newValue
            // print("Tile \(tile) changed value from \(oldValue ?? Tile.void) to \(newValue)")
            
            /*tileDidChangedEventHandlers.forEach {
                $0(tile, oldValue, newValue)
            }*/
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
    
    static func coordinatesWithinRange(from tile: AxialCoord, range: Int) -> [AxialCoord] {
        let result = coordinatesWithinRange(from: tile.toCube(), range: range)
        return result.map { tile in
            tile.toAxial()
        }
    }
    
    static func coordinatesIntersectingRanges(from tileA: CubeCoord, withRange rangeTileA: Int, to TileB: CubeCoord, withRange rangeTileB: Int) -> [CubeCoord] {
        let coordinatesInRangeOfTileA = coordinatesWithinRange(from: tileA, range: rangeTileA)
        let coordinatesInRangeOfTileB = coordinatesWithinRange(from: TileB, range: rangeTileB)
        
        return coordinatesInRangeOfTileA.filter {
            coordinatesInRangeOfTileB.contains($0)
        }
    }
    
    func reachableFromTile(_ startTile: CubeCoord, movement: Int, movementCosts: [Tile: Double] = Tile.defaultCostsToEnter) -> [CubeCoord] {
        var visited = Set<CubeCoord>()
        visited.insert(startTile)
        var fringes = [Set<CubeCoord>()]
        fringes.append(visited)
        
        for k in 2 ... movement {
            fringes.append(Set<CubeCoord>())
            for hex in fringes[k - 1] {
                for dir in 0 ..< 6 {
                    let neighbourCube = toWrappedCoord(HexMap.cubeNeighbourCoord(tile: hex, directionIndex: dir).toAxial()).toCube()
                    let neighbourHexCoord = neighbourCube.toAxial()
                    let tile = self[neighbourHexCoord.q, neighbourHexCoord.r]
                    if visited.contains(neighbourCube) == false && movementCosts[tile, default: -1] >=	 0 {
                        visited.insert(neighbourCube)
                        fringes[k].insert(neighbourCube)
                    }
                }
            }
        }
        return Array(visited)
    }
    
    func toWrappedCoord(_ coord: AxialCoord) -> AxialCoord {
        switch wrapType {
        case .none:
            return coord
        case .horizontal:
            let halfQ = width / 2
            if coord.q < -halfQ - qOffsetFor(row: coord.r) {
                return AxialCoord(q: halfQ - qOffsetFor(row: coord.r), r: coord.r)
            } else if coord.q > halfQ - qOffsetFor(row: coord.r) {
                return AxialCoord(q: -halfQ - qOffsetFor(row: coord.r), r: coord.r)
            } else {
                return coord
            }
        }
    }
    
    func toWrappedCoordinates(_ coords: [AxialCoord]) -> [AxialCoord] {
        coords.map { toWrappedCoord($0) }
    }
    
    // MARK: GameplayKit Pathfinding
    
    // we use this function to rebuild the pathfinding graph. this is required for instance
    // when terrain changes. 
    func rebuildPathFindingGraph(movementCosts: [Tile: Double] = Tile.defaultCostsToEnter, additionalEnterableTiles: [AxialCoord] = []) -> (graph: GKGraph, tileCoordToNodeMap: [AxialCoord : HexGraphNode]) {
        
        let pathfindingGraph = GKGraph()
        var tileCoordToNodeMap = [AxialCoord : HexGraphNode]()
        var nodes = [HexGraphNode]()
        
        // transform between tiles and nodes using dictionary
        // nodes can know what coordinate they apply to.
        tiles.forEach {
            let node: HexGraphNode
            if additionalEnterableTiles.contains($0.key) {
                node = HexGraphNode(hexMapCoordinate: $0.key, costToEnter: 0.5)
            } else {
                node = HexGraphNode(hexMapCoordinate: $0.key,costToEnter: movementCosts[$0.value, default: -1])
            }
            tileCoordToNodeMap[$0.key] = node
            nodes.append(node)
        }
    
        nodes.forEach {
            let node = $0
            let coord = $0.hexMapCoordinate
            
            let rawNeighbours = HexMap.getAxialNeighbourCoordinates(tile: coord)
            let neighbours = toWrappedCoordinates(rawNeighbours)
            
            neighbours.forEach {
                if movementCosts[self[$0], default: -1] >= 0 || additionalEnterableTiles.contains($0){
                    node.addConnections(to: [tileCoordToNodeMap[$0]!], bidirectional: false)
                }
            }
        }
        
        pathfindingGraph.add(nodes)
        
        return (pathfindingGraph, tileCoordToNodeMap)
    }
    
    func findPathFrom(_ tile1: AxialCoord, to tile2: AxialCoord, pathfindingGraph: GKGraph, tileCoordToNodeMap: [AxialCoord : HexGraphNode], movementCosts: [Tile: Double] = Tile.defaultCostsToEnter) -> [AxialCoord]? {
        if let node1 = tileCoordToNodeMap[tile1], let node2 = tileCoordToNodeMap[tile2] {
            let nodePath = pathfindingGraph.findPath(from: node1, to: node2)
            
            var result = [AxialCoord]()
            var cost = 0.0
            nodePath.forEach {
                let coord = ($0 as! HexGraphNode).hexMapCoordinate
                cost += movementCosts[self[coord], default: 0]
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

struct AxialCoord: Equatable, Hashable, CustomStringConvertible, Codable {
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

enum Tile: Int, Codable {
    
    struct TileYield: Codable, CustomStringConvertible, Equatable {
        let food: Double
        let production: Double
        let gold: Double
        let science: Double
        let culture: Double
        
        init(food: Double = 0, production: Double = 0, gold: Double = 0, science: Double = 0, culture: Double = 0) {
            self.food = food
            self.production = production
            self.gold = gold
            self.science = science
            self.culture = culture
        }
        
        static func +(lhs: TileYield, rhs: TileYield) -> TileYield {
            return TileYield(food: lhs.food + rhs.food, production: lhs.production + rhs.production, gold: lhs.gold + rhs.gold, science: lhs.science + rhs.science, culture: lhs.culture + rhs.culture)
        }
        
        static func += (left: inout TileYield, right: TileYield) {
            left = left + right
        }
        
        var description: String {
            "\(food)🥖, \(production)⚒️, \(gold)💎, \(science)🧪, \(culture)🎵"
        }
    }
    
    case void
    case Water
    case Sand
    case Grass
    case Forest
    case Hill
    case Mountain
    
    //var blocksMovement: Bool {
    //    return costToEnter < 0
    //}
    
    /*var costToEnter: Double {
        switch self {
        case .Grass:
            return 1.0
        case .Sand:
            return 1.0
        case .Forest:
            return 2
        case .Hill:
            return 1.5
        default:
            return -1
        }
    }*/
    
    static var defaultCostsToEnter: [Tile: Double] {
        [
        .void: -1,
        .Water: -1,
        .Sand: 1,
        .Grass: 1,
        .Forest: 2,
        .Hill: 1.5,
        .Mountain: -1
        ]
    }
    
    var stringValue: String {
        switch self {
        case .void:
            return "Void"
        case .Water:
            return "Water"
        case .Sand:
            return "Sand"
        case .Grass:
            return "Grass"
        case .Forest:
            return "Forest"
        case .Mountain:
            return "Mountain"
        case .Hill:
            return "Hills"
        }
    }
    
    var baseTileYield: TileYield {
        switch self {
        case .void:
            return TileYield(food: 0, production: 0, gold: 0)
        case .Water:
            return TileYield(food: 0, production: 1, gold: 1)
        case .Sand:
            return TileYield(food: 1, production: 1, gold: 1)
        case .Grass:
            return TileYield(food: 2, production: 1, gold: 1)
        case .Forest:
            return TileYield(food: 1, production: 1, gold: 1)
        case .Mountain:
            return TileYield(food: 1, production: 0, gold: 2)
        case .Hill:
            return TileYield(food: 1, production: 2, gold: 1)
        }
    }
}

class HexGraphNode: GKGraphNode {
    let cost: Double
    let hexMapCoordinate: AxialCoord
    
    init(hexMapCoordinate: AxialCoord, costToEnter: Double = 1.0) {
        self.hexMapCoordinate = hexMapCoordinate
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
