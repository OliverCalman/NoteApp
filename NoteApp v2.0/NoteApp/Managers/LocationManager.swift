//
//  LocationManager.swift
//  NoteApp
//
//  Created by yuchen on 11/5/2025.
//

// LocationManager.swift
import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    @Published var lastLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.last else { return }
        lastLocation = loc.coordinate
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
