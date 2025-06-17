// WeatherManager.swift

import Foundation
import CoreLocation

class WeatherManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var completion: ((Double, Double) -> Void)?

    func requestLocation(completion: @escaping (Double, Double) -> Void) {
        self.completion = completion
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print("위치 수신됨: lat = \(lat), lon = \(lon)")
            completion?(lat, lon)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 가져오기 실패: \(error.localizedDescription)")
    }
}

