import Foundation
import AVFoundation

/// Handles mic permission, start/stop recording, and exposes the temp file URL.
class AudioRecorder: NSObject, ObservableObject {
    @Published var recording = false
    /// URL of the file currently being recorded
    private(set) var audioFilename: URL?
    private var recorder: AVAudioRecorder?

    override init() {
        super.init()
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("⚠️ Microphone permission denied")
            }
        }
    }

    /// Starts a new .m4a recording in Documents/
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            let docs = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = UUID().uuidString + ".m4a"
            let url = docs.appendingPathComponent(filename)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12_000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.delegate = self
            recorder?.record()

            audioFilename = url
            recording = true
        } catch {
            print("⚠️ Failed to start recording:", error)
        }
    }

    /// Stops and finalises the recording
    func stopRecording() {
        recorder?.stop()
        recording = false
    }
}

extension AudioRecorder: AVAudioRecorderDelegate { }
