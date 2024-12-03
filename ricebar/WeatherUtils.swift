//
//  Weather.swift
//  ricebar
//
//  Created by Joy Liu on 12/3/24.
//

import SwiftUI
import CoreLocation

struct Weather: Encodable, Decodable {
    let temperature: Double
    let weatherCode: Int
    let precipitationProbability: Double
    let precipitation: Double
    let time: String
    
    var weatherType: String {
        switch weatherCode {
            case 0: return "Clear sky"
            case 1, 2, 3: return "Partly cloudy"
            case 45, 48: return "Foggy"
            case 51, 53, 55: return "Drizzle"
            case 61, 63, 65: return "Rain"
            case 71, 73, 75: return "Snowfall"
            case 80, 81, 82: return "Rain showers"
            case 95: return "Thunderstorm"
            default: return "Unknown"
        }
    }
    
    var symbol: String {
        switch weatherCode {
            case 0: return "sun.max"
            case 1, 2, 3: return "cloud.sun"
            case 45, 48: return "cloud.fog"
            case 51, 53, 55: return "cloud.drizzle"
            case 61, 63, 65: return "cloud.rain"
            case 71, 73, 75: return "cloud.snow"
            case 80, 81, 82: return "cloud.heavyrain"
            case 95: return "cloud.bolt"
            default: return "questionmark"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case temperature
        case weatherCode = "weathercode"
        case precipitationProbability = "precipitation_probability"
        case precipitation
        case time
    }
}

struct CurrentWeather: Decodable {
    let temperature: Double
    let weatherCode: Int
    let time: String

    private enum CodingKeys: String, CodingKey {
        case temperature
        case weatherCode = "weathercode"
        case time
    }
}

struct HourlyWeatherData: Encodable, Decodable {
    let time: [String]
    let precipitation: [Double]
    let precipitationProbability: [Double]

    private enum CodingKeys: String, CodingKey {
        case time
        case precipitation
        case precipitationProbability = "precipitation_probability"
    }
}

struct WeatherResponse: Decodable {
    let currentWeather: CurrentWeather
    let hourly: HourlyWeatherData

    private enum CodingKeys: String, CodingKey {
        case currentWeather = "current_weather"
        case hourly
    }
    
    func getWeather() -> Weather? {
        let currentTime = currentWeather.time.prefix(13)
        guard let index = hourly.time.firstIndex(where: { $0.starts(with: currentTime) }) else {
            print("Current time not found in hourly data!")
            return nil
        }
        print("Current hour time: \(currentTime), Hourly times: \(self.hourly.time)")

        if let index = hourly.time.firstIndex(where: { $0.starts(with: currentTime) }) {

            let precipitation = self.hourly.precipitation[index]
            let probability = self.hourly.precipitationProbability[index]
            return Weather(temperature: self.currentWeather.temperature, weatherCode: self.currentWeather.weatherCode, precipitationProbability: probability, precipitation: precipitation, time: String(currentTime))
        } else {
            print("Current time not found in hourly data!")
            return nil
        }
    }

}

