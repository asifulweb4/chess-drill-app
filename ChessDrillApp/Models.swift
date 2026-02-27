import Foundation

// Chess piece types
enum PieceType: String, Codable {
    case king = "♔"
    case queen = "♕"
    case rook = "♖"
    case bishop = "♗"
    case knight = "♘"
    case pawn = "♙"
    
    case kingBlack = "♚"
    case queenBlack = "♛"
    case rookBlack = "♜"
    case bishopBlack = "♝"
    case knightBlack = "♞"
    case pawnBlack = "♟"
}

// Chess piece model
struct ChessPiece: Identifiable, Codable, Equatable {
    let id: UUID
    let type: PieceType
    var position: BoardPosition
    
    init(type: PieceType, position: BoardPosition) {
        self.id = UUID()
        self.type = type
        self.position = position
    }
}

// Board position
struct BoardPosition: Codable, Equatable, Hashable {
    let row: Int
    let col: Int
    
    var notation: String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        let rank = 8 - row
        return "\(files[col])\(rank)"
    }
}

// Drill model
struct Drill: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var pieces: [ChessPiece]
    var createdAt: Date
    
    init(name: String, description: String, pieces: [ChessPiece]) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.pieces = pieces
        self.createdAt = Date()
    }
    
    func toJSONString() -> String? {
        if let data = try? JSONEncoder().encode(self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
