//
//  WeatherApiClient.swift
//  WeatherApp
//
//  Created by Sam King on 1/30/19.
//  Copyright © 2019 Sam King. All rights reserved.
//

/***************
 
 TODO:
 1. Implement error handling with WeatherApiClient in completion func for retrieveDarkSkyWeather()
 
 ***************/

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SVProgressHUD

import PromiseKit

struct WeatherApiConfig {
    
    //MARK: - Dark Sky API Config
    static let dwBaseURL = URL(string: "https://api.darksky.net/forecast/")!
    static var dwAuthenticatedBaseURL: URL {
        return dwBaseURL.appendingPathComponent(DarkSkyConfig.apikey)
    }
    
    //MARK: - place other API Configs below
    
}

final class WeatherApiClient {
    
    let baseUrl: URL
    
    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }
    
    //MARK: - Dark Sky API
    static let sharedDSWApi: WeatherApiClient = {
        return WeatherApiClient(baseUrl: WeatherApiConfig.dwAuthenticatedBaseURL)
    }()
    
    func makeDarkSkyAPIUrl(path: String) -> URL {
        return baseUrl.appendingPathComponent(path)
    }
    
    func darkSkyPromise(latitude: String,
                        longitude: String) -> Promise<Void>{
        let location = latitude + "," + longitude
        let url = makeDarkSkyAPIUrl(path: location)
        WeatherStore.shared.weatherApiType = DarkSkyConfig.apiname
        
        return Promise { seal in
            Alamofire.request(url, method: .get).validate().responseObject {
                (response: DataResponse<DarkSkyWeather>) in
                switch response.result {
                case .success:
                    if let darkSkyWeather = response.result.value {
                        UserDefaults.standard.set(String(darkSkyWeather.currentTemp ?? 0), forKey: "currentTemperature")
                        UserDefaults.standard.set(darkSkyWeather.currentTempIcon ?? "rainy", forKey: "currentWeatherIcon")
                        UserDefaults.standard.set(darkSkyWeather.forecastSum ?? "0", forKey: "forecastSummary")
                        UserDefaults.standard.set(darkSkyWeather.forecastTempIcon ?? "rainy", forKey: "forecastWeatherIcon")
                        seal.fulfill_()
                    } else {
                        seal.reject(WeatherApiError.darkSkyDataError)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
