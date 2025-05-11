import SwiftUI
import AVFoundation

/// Drop-in UI for recording, playing back, and deleting a voice memo on your NoteModel.
struct VoiceMemoControls: View {
    @Binding var note: NoteModel
    @StateObject private var recorder = AudioRecorder()
    @State private var player: AVAudioPlayer?

    var body: some View {
        Group {
            // ── If there’s already a memo file stored for this note ID:
            if let url = AudioMemoStore.shared.url(for: note.id) {
                HStack(spacing: 16) {
                    Button { play(url) } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                    Button { deleteMemo() } label: {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }

            // ── Otherwise show record/stop UI:
            } else {
                if recorder.recording {
                    Button("Stop Recording") {
                        recorder.stopRecording()
                        if let fileURL = recorder.audioFilename {
                            AudioMemoStore
                                .shared
                                .set(filename: fileURL.lastPathComponent, for: note.id)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)

                } else {
                    Button("Record Voice Memo") {
                        recorder.startRecording()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }

    private func play(_ url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Playback error:", error)
        }
    }

    private func deleteMemo() {
        AudioMemoStore.shared.set(filename: nil, for: note.id)
    }
}
