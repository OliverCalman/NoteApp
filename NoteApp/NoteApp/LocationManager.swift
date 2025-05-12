import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var locationDescription: String? = nil
    @Published var coordinate: CLLocationCoordinate2D? = nil

    // 🧭 fallback 用于模拟器或定位失败时
    let fallbackCoordinate = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            fallbackToSydney()
            return
        }
        coordinate = location.coordinate
        reverseGeocode(location)
        locationManager.stopUpdatingLocation()
    }

    func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first,
               let suburb = placemark.locality,
               let postcode = placemark.postalCode,
               let state = placemark.administrativeArea,
               state == "NSW" {
                self?.locationDescription = "\(suburb) NSW \(postcode)"
            } else {
                self?.fallbackToSydney()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        fallbackToSydney()
    }

    private func fallbackToSydney() {
        locationDescription = "Ultimo NSW 2007"
        coordinate = fallbackCoordinate
    }
}
