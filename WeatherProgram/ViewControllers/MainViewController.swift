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
            URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=39.06983&lon=-9.37174&appid=e0c7a44adf56691bf2df15b4b044c1db&units=metric")
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
    @IBOutlet var weatherImageLabel: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var temperatureFeelingLabel: UILabel!
    @IBOutlet var temperatureMaxMinLabel: UILabel!
    
    var weatherData: WeatherResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitleView()
        updateMainLabelView()
        updateBackButton()
    }
    
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
    
    func loadWeatherIcon(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.weatherImageLabel.image = UIImage(data: data)
                }
            } else {
                DispatchQueue.main.async {
                    self.weatherImageLabel.image = UIImage(systemName: "thermometer.high")
                }
            }
        }
        task.resume()
    }
}

// MARK: - Setup UI
private extension MainViewController {
    func updateTitleView() {
        guard let weatherData = weatherData else {
            return
        }
        
        let titleLabel = UILabel()
        titleLabel.text = weatherData.name
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = weatherData.sys.country
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        
        navigationItem.titleView = stackView
    }
    
    func updateMainLabelView() {
        guard let weatherData = weatherData else {
            return
        }
        
        if let iconCode = weatherData.weather.first?.icon {
            let iconURLString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
            if let iconURL = URL(string: iconURLString) {
                loadWeatherIcon(from: iconURL)
            }
        }
        
        temperatureLabel.text = "\(Int(weatherData.main.temp))°C"
        temperatureFeelingLabel.text = "Feels like \(Int(weatherData.main.feelsLike))°C"
        temperatureMaxMinLabel.text = "Max: \(Int(weatherData.main.tempMax))°C, Min:  \(Int(weatherData.main.tempMin))°C"
    }
    
    func updateBackButton() {
        let backButton = UIBarButtonItem()
        backButton.tintColor = .orange
        navigationItem.backBarButtonItem = backButton
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
            self.weatherData = weatherResponse
            
            DispatchQueue.main.async { [weak self] in
                self?.hideActivityIndicator()
                self?.showAlert(withStatus: .success)
                self?.updateTitleView()
                self?.updateMainLabelView()
                
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

