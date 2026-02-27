import SwiftUI

struct ChessBoardView: View {
    @Binding var pieces: [ChessPiece]
    @State private var practicePieces: [ChessPiece] = []
    @State private var selectedPiece: ChessPiece?
    @State private var showPiecePicker = false
    var isPracticeMode: Bool = false
    var onReset: (() -> Void)? = nil
    var displayPieces: [ChessPiece] {
        isPracticeMode ? practicePieces : pieces
    }
    var boardSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return min(screenWidth - 40, 400)
    }
    
    var squareSize: CGFloat { boardSize / 8 }
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            squareView(row: row, col: col)
                        }
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .border(Color.gray, width: 2)
            HStack(spacing: 20) {
                Button(action: { showPiecePicker = true }) {
                    Label("Add Piece", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isPracticeMode)
                if isPracticeMode {
                    Button(action: resetPractice) {
                        Label("Reset Position", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: clearBoard) {
                        Label("Clear Board", systemImage: "trash.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .sheet(isPresented: $showPiecePicker) {
            PiecePickerView(pieces: $pieces)
        }
        .onAppear {
            if isPracticeMode {
                practicePieces = pieces
            }
        }
    }
    private func squareView(row: Int, col: Int) -> some View {
        let position = BoardPosition(row: row, col: col)
        let isLight = (row + col) % 2 == 0
        let piece = displayPieces.first { $0.position == position }
        return ZStack {
            Rectangle()
                .fill(isLight ? Color(white: 0.9) : Color(red: 0.7, green: 0.5, blue: 0.3))
            if let piece = piece {
                Text(piece.type.rawValue)
                    .font(.system(size: squareSize * 0.6))
                    .onTapGesture {
                        selectedPiece = piece
                    }
            }
        }
        .frame(width: squareSize, height: squareSize)
        .onTapGesture {
            if let selected = selectedPiece {
                movePiece(selected, to: position)
                selectedPiece = nil
            }
        }
        .overlay(
            selectedPiece?.position == position ?
            Rectangle().stroke(Color.yellow, lineWidth: 3) : nil
        )
    }
    private func movePiece(_ piece: ChessPiece, to position: BoardPosition) {
        if isPracticeMode {
            practicePieces.removeAll { $0.position == position }
            if let index = practicePieces.firstIndex(where: { $0.id == piece.id }) {
                practicePieces[index].position = position
            }
        } else {
            pieces.removeAll { $0.position == position }
            if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
                pieces[index].position = position
            }
        }
    }
    private func resetPractice() {
        practicePieces = pieces
    }
    private func clearBoard() {
        pieces.removeAll()
    }
}

struct PiecePickerView: View {
    @Binding var pieces: [ChessPiece]
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: PieceType = .pawn
    @State private var selectedRow = 0
    @State private var selectedCol = 0
    let whitePieces: [PieceType] = [.king, .queen, .rook, .bishop, .knight, .pawn]
    let blackPieces: [PieceType] = [.kingBlack, .queenBlack, .rookBlack, .bishopBlack, .knightBlack, .pawnBlack]
    var body: some View {
        NavigationView {
            Form {
                Section("Select Piece") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("White Pieces").font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                            ForEach(whitePieces, id: \.self) { piece in
                                pieceButton(piece)
                            }
                        }
                        Text("Black Pieces").font(.headline).padding(.top)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                            ForEach(blackPieces, id: \.self) { piece in
                                pieceButton(piece)
                            }
                        }
                    }
                }
                Section("Position") {
                    Picker("Row (Rank)", selection: $selectedRow) {
                        ForEach(0..<8, id: \.self) { row in
                            Text("\(8 - row)").tag(row)
                        }
                    }
                    Picker("Column (File)", selection: $selectedCol) {
                        ForEach(0..<8, id: \.self) { col in
                            Text(["a", "b", "c", "d", "e", "f", "g", "h"][col]).tag(col)
                        }
                    }
                }
                Button("Add Piece") {
                    addPiece()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Add Chess Piece")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
    private func pieceButton(_ piece: PieceType) -> some View {
        Button(action: { selectedType = piece }) {
            Text(piece.rawValue)
                .font(.system(size: 40))
                .frame(width: 50, height: 50)
                .background(selectedType == piece ? Color.blue.opacity(0.3) : Color.clear)
                .cornerRadius(8)
        }
    }
    private func addPiece() {
        let position = BoardPosition(row: selectedRow, col: selectedCol)
        pieces.removeAll { $0.position == position }
        let newPiece = ChessPiece(type: selectedType, position: position)
        pieces.append(newPiece)
    }
}
