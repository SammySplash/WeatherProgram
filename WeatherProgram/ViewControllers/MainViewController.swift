//
//  MainViewController.swift
//  WeatherProgram
//
//  Created by Samoilik Hleb on 06/04/2025.
//

import UIKit

enum Link {
    case openWeatherMapAPI
    
    var url: URL? {
        switch self {
            case .openWeatherMapAPI:
            URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=39.06983&lon=-9.37174&appid=2cd38519fec3038fa17a5d9cbd3ef35d&units=metric")
        }
    }
}

enum Alert {
    case success
    case failure
    
    var title: String {
        switch self {
        case .success:
            "Success"
        case .failure:
            "Failure"
        }
    }
    
    var message: String {
        switch self {
        case .success:
            "Request successful"
        case .failure:
            "Request failed"
        }
    }
}

final class MainViewController: UIViewController {
    @IBOutlet var fetchWeatherButton: UIButton!
    
    @IBAction func fetchWeatherButtonTapped() {
        fetchWeather()
    }
}

// MARK: - Networking
private extension MainViewController {
    func fetchWeather() {
        showActivityIndicator()
        
        guard let url = Link.openWeatherMapAPI.url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            guard let data = data else {
                self.handleError(error?.localizedDescription ?? "No data received.")
                return
            }
            
            if let error = error {
                self.handleError(error.localizedDescription)
                return
            }
            
            self.decodeWeatherData(data)
        }.resume()
    }
}

// MARK: - Error Handling
private extension MainViewController {
    func handleError(_ errorMessage: String) {
        DispatchQueue.main.async { [weak self] in
            self?.hideActivityIndicator()
            self?.showAlert(withStatus: .failure)
            print("Error: \(errorMessage)")
        }
    }
}

// MARK: - JSON Decoding
private extension MainViewController {
    func decodeWeatherData(_ data: Data) {
        let decoder = JSONDecoder()
        
        do {
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.hideActivityIndicator()
                self?.showAlert(withStatus: .success)
                print("You've chosen a \(weatherResponse.name), \(weatherResponse.sys.country)")
                print("Air temperature now is \(weatherResponse.main.temp) and feels like \(weatherResponse.main.feelsLike) degrees Celsius.")
                print("Wind speed: \(weatherResponse.wind.speed) m/s.")
            }
        } catch {
            handleError(error.localizedDescription)
        }
    }
}

// MARK: - Internal Methods
private extension MainViewController {
    func showAlert(withStatus status: Alert) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: status.title,
                message: status.message,
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - Activity Indicator
private extension MainViewController {
    func showActivityIndicator() {
        var config = UIContentUnavailableConfiguration.loading()
        config.text = "Waiting for a response..."
        config.textProperties.color = .systemBlue
        config.textProperties.font = .boldSystemFont(ofSize: 20)
        
        contentUnavailableConfiguration = config
        fetchWeatherButton.isHidden = true
    }
    
    func hideActivityIndicator() {
        contentUnavailableConfiguration = nil
        fetchWeatherButton.isHidden = false
    }
}
