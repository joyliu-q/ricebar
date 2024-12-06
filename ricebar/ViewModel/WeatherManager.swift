//
//  WeatherManager.swift
//  ricebar
//
//  Created by Joy Liu on 12/2/24.
//

import SwiftUI
import CoreLocation

struct Location: Decodable, Hashable, Encodable {
    let lat: Double
    let lon: Double
    
    init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    func fetchWeather() async throws -> Weather? {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(self.lat)&longitude=\(self.lon)&current_weather=true&hourly=precipitation_probability,precipitation"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return response.getWeather()
    }
    
    static var mock: Location {
        Location(lat: 45.5152, lon: -122.6784)
    }
}

class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: Weather?
    
    private var locationManager: CLLocationManager?

    override init() {
        super.init()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestUserLocation() {
        if locationManager == nil {
            setupLocationManager()
        }
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeather(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    func fetchWeather(for location: CLLocation?) {
        guard let location = location else {
            print("No location available")
            return
        }
        
        Task {
            do {
                let loc = Location(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                let weather = try await loc.fetchWeather()

                await MainActor.run {
                    self.weather = weather
                }
            } catch {
                print("Error fetching location or weather: \(error)")
            }
        }
    }
    
}
