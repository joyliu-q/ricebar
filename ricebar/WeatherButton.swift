import SwiftUI

struct WeatherButton: View {
    @StateObject private var weatherManager = WeatherManager()
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: weatherManager.weather?.symbol ?? "circle.dashed")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                
                if let temp = weatherManager.weather?.temperature {
                    Text(String(format: "%.0f°", temp))
                        .foregroundColor(.white)
                } else {
                    Text("--°")
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            weatherManager.requestUserLocation()
        }
    }
} 
