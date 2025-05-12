import SwiftUI
import MapKit

struct NoteDetailView: View {
    let note: NoteModel

    @State private var cameraPosition: MapCameraPosition

    init(note: NoteModel) {
        self.note = note

        if let coord = note.coordinate {
            _cameraPosition = State(initialValue:
                .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            )
        } else {
            _cameraPosition = State(initialValue:
                .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                ))
            )
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            if let coord = note.coordinate {
                Map(position: $cameraPosition) {
                    Marker(note.locationText ?? "Note", coordinate: coord)
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding()

                Button(action: openInMaps) {
                    Label("Open in Maps", systemImage: "map.fill")
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            } else {
                Text("No GPS location available.")
                    .foregroundColor(.gray)
                    .padding()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(note.text.isEmpty ? "No content" : note.text)
                    .font(.body)

                if let location = note.locationText {
                    Text("📍 \(location)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("🗂 Category: \(note.category)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !note.tags.isEmpty {
                    Text("🏷 Tags: \(note.tags.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Note Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openInMaps() {
        guard let coord = note.coordinate else { return }
        let placemark = MKPlacemark(coordinate: coord)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = note.locationText ?? "Note Location"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
