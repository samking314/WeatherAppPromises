//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Sam King on 1/29/19.
//  Copyright © 2019 Sam King. All rights reserved.
//

/***************
 
 TODO:
 1. Indicate the location of the weather(uilabel maybe below 'Current Weather' in main.storyboard)
 
 ***************/

import UIKit
import SVProgressHUD
import CoreLocation
import UserNotifications

import PromiseKit
import Alamofire

class WeatherViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate{
    
    let currWeather: CurrentWeather = .fromNib()
    var foreWeather: ForecastWeather = .fromNib()
    
    let geoCoder = CLGeocoder()
    
    @IBOutlet weak var locationTextField: UITextField!{
        didSet{
            locationTextField.delegate = self
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWeatherScrollView()
        
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        
        var loc = Locator.main.location
        load(location: &loc)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadUI()
    }

    func setupWeatherScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        
        setupCustomViews()
        
        scrollView.addSubview(currWeather)
        scrollView.addSubview(foreWeather)
    }
    
    func setupCustomViews() {
        currWeather.frame = CGRect(x: scrollView.frame.size.width * 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        foreWeather.frame = CGRect(x: scrollView.frame.size.width * 1, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
    }
    
    func load(location: inout CLLocation?) {
        if location == nil {
            guard Locator.main.location != nil else { return }
            location = Locator.main.location
        }
        guard let loc = location else { return }
        SVProgressHUD.show()
        let queue = DispatchQueue(label: "com.WeatherApp.Background", qos: .background)
        queue.async {
            firstly {
                when(fulfilled: WeatherApiClient.sharedDSWApi.darkSkyPromiseURLSession(latitude: String(loc.coordinate.latitude), longitude: String(loc.coordinate.longitude)))
                }.done { [weak self] in
                    self?.reloadUI()
                }.ensure {
                    SVProgressHUD.popActivity()
                }.catch { error in
                    Alert.error(vc: self, message: error.localizedDescription)
            }
        }
    }
    
    func reloadUI() {
        if let currtemp = WeatherStore.shared.currentTemperature {
            self.currWeather.temp.text = String(currtemp) + "°F"
        }
        if let curricon = WeatherStore.shared.currentWeatherIcon {
            self.currWeather.icon.text = String(curricon)
        }
        if let foresum = WeatherStore.shared.forecastSummary {
            self.foreWeather.forecast.text = String(foresum)
        }
        if let foreicon = WeatherStore.shared.forecastWeatherIcon {
            self.foreWeather.icon.text = String(foreicon)
        }
    }
    
    func checkReloadUI() {
        let same = checkWeatherChanged()
        if !same {
            reloadUI()
        }
    }
    
    //MARK: - Scrollview Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    //MARK: - Textfield Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        geoCoder.geocodeAddressString(locationTextField.text ?? "") { [weak self] (placemark, error) in
            guard let place = placemark else {
                guard let self = self else { return }
                Alert.error(vc: self, message: "Unable to find this location. Please enter a different location.")
                return
            }
            var location: CLLocation? = place.first?.location
            self?.load(location: &location)
        }
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Helper Methods
    func checkWeatherChanged() -> Bool {
        if let currtemp = WeatherStore.shared.currentTemperature,
            let curricon = WeatherStore.shared.currentWeatherIcon,
            let foresum = WeatherStore.shared.forecastSummary,
            let foreicon = WeatherStore.shared.forecastWeatherIcon{
            if String(currtemp) + "°F" == self.currWeather.temp.text,
                String(curricon) == self.currWeather.icon.text,
                String(foresum) == self.foreWeather.forecast.text,
                String(foreicon) == self.foreWeather.icon.text {
                return true
            }
        }
        return false
    }
   
}

