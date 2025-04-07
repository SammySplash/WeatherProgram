//
//  RequestAPI.swift
//  WeatherProgram
//
//  Created by Samoilik Hleb on 07/04/2025.
//

import Foundation

struct WeatherResponse: Decodable {
    let location: Location
    let current_observation: CurrentObservation
    let forecasts: [Forecast]
}

struct Location: Decodable {
    let city: String
    let woeid: Int
    let country: String
    let lat: Double
    let long: Double
    let timezone_id: String
}

struct CurrentObservation: Decodable {
    let pubDate: Int
    let wind: Wind
    let atmosphere: Atmosphere
    let astronomy: Astronomy
    let condition: Condition
    
    struct Wind: Decodable {
        let chill: Int
        let direction: String
        let speed: Int
    }
    
    struct Atmosphere: Decodable {
        let humidity: Int
        let visibility: Double
        let pressure: Double
    }
    
    struct Astronomy: Decodable {
        let sunrise: String
        let sunset: String
    }
    
    struct Condition: Decodable {
        let temperature: Int
        let text: String
        let code: Int
    }
}

struct Forecast: Decodable {
    let day: String
    let date: Int
    let high: Int
    let low: Int
    let text: String
    let code: Int
}

