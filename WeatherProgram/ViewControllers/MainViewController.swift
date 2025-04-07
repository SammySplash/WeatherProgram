//
//  MainViewController.swift
//  WeatherProgram
//
//  Created by Samoilik Hleb on 06/04/2025.
//

import UIKit

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
        
        let url = "https://yahoo-weather5.p.rapidapi.com/weather?location=S%C3%A3o%20Pedro%20da%20Cadeira&format=json&u=c"
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let headers = [
            "x-rapidapi-host": "yahoo-weather5.p.rapidapi.com",
            "x-rapidapi-key": "d68f19ebbdmshd781a2a159cb03ep1de912jsn0889134c43d4"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            guard let data = data else {
                self.handleError("No data received.")
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
                print(weatherResponse.location.city)
                print(weatherResponse.current_observation.condition.temperature)
                print(weatherResponse.forecasts.first?.text ?? "No forecast available")
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
