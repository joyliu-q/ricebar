import SwiftUI

class PongGame: ObservableObject {
    static let shared = PongGame()
    
    @Published var ballPosition: CGPoint = CGPoint(x: 400, y: 300)
    @Published var ballVelocity: CGPoint = CGPoint(x: 5, y: -5)
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    
    var timer: Timer?
    var paddlePosition: CGFloat = 0
    
    func startGame() {
        isGameOver = false
        score = 0
        ballPosition = CGPoint(x: 400, y: 300)
        ballVelocity = CGPoint(x: 5, y: -5)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in
            self?.updateBall()
        }
    }
    
    func updateBall() {
        ballPosition.x += ballVelocity.x
        ballPosition.y += ballVelocity.y
        
        let screenFrame = NSScreen.main?.frame ?? .zero
        
        if ballPosition.x <= 0 || ballPosition.x >= screenFrame.width {
            ballVelocity.x *= -1
        }
        
        if ballPosition.y >= screenFrame.height {
            ballVelocity.y *= -1
        }
        
        if ballPosition.y <= 50 {
            let paddleWidth: CGFloat = screenFrame.width / 2 - 105
            if abs(ballPosition.x - paddlePosition) < paddleWidth/2 {
                ballVelocity.y *= -1
                score += 1
                ballVelocity.x *= 1.1
                ballVelocity.y *= 1.1
            } else if ballPosition.y <= 0 {
                endGame()
            }
        }
    }
    
    func endGame() {
        timer?.invalidate()
        timer = nil
        isGameOver = true
    }
    
    func updatePaddlePosition(_ position: CGFloat) {
        paddlePosition = position
    }
}

struct PongView: View {
    @StateObject private var game = PongGame.shared
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 10, height: 10)
                    .position(game.ballPosition)
                
                if game.isGameOver {
                    VStack(spacing: 20) {
                        Text("Game Over!")
                            .font(.title)
                            .foregroundColor(.white)
                            .bold()
                        Text("Score: \(game.score)")
                            .font(.title)
                            .foregroundColor(.white)
                        HStack(spacing: 20) {
                            Button("Play Again") {
                                game.startGame()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Quit") {
                                game.endGame()
                                 if let window = NSApp.windows.first(where: { $0.title == "Pong" }) {
                                     window.isReleasedWhenClosed = false
                                     window.close()
                                 }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                    .padding(24)
                    .background(DEFAULT_BACKGROUND.timeVaryingShader())
                    .cornerRadius(16)
                    .shadow(radius: 10)
                } else {
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Text("Score: \(game.score)")
                            .font(.title3)
                            .foregroundColor(.white)
                        }
                        .padding(12)
                        .frame(minWidth: 100)
                        .background(DEFAULT_BACKGROUND.timeVaryingShader())
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                    .padding(24)
                    .position(x: geometry.size.width - 100, y: 50)
                        
                }
            }
        }
        .onAppear {
            game.startGame()
        }
    }
    
    static func updatePaddlePosition(_ position: CGFloat) {
        PongGame.shared.updatePaddlePosition(position)
    }
} 
