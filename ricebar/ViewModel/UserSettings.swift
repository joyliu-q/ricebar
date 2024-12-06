import SwiftUI
import Combine

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var backgroundColor: Color
    @Published var shaderBaseColor: Color
    
    @AppStorage("backgroundColor") private var backgroundColorData: Data = Data()
    @AppStorage("shaderBaseColor") private var shaderBaseColorData: Data = Data()
    
    private init() {
        self._backgroundColor = Published(initialValue: .defaultPrimary)
        self._shaderBaseColor = Published(initialValue: .blue)
        
        if let color = try? JSONDecoder().decode(Color.self, from: backgroundColorData) {
            backgroundColor = color
        }
        
        if let color = try? JSONDecoder().decode(Color.self, from: shaderBaseColorData) {
            shaderBaseColor = color
        }
        
        setupObservers()
    }
    
    private func setupObservers() {
        $backgroundColor.sink { [weak self] newColor in
            if let encoded = try? JSONEncoder().encode(newColor) {
                self?.backgroundColorData = encoded
            }
        }.store(in: &cancellables)
        
        $shaderBaseColor.sink { [weak self] newColor in
            if let encoded = try? JSONEncoder().encode(newColor) {
                self?.shaderBaseColorData = encoded
            }
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}
