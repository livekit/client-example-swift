import SwiftUI
import LiveKit

#if !os(macOS)
import UIKit
public typealias NativeViewRepresentable = UIViewRepresentable
#else
// macOS
import AppKit
public typealias NativeViewRepresentable = NSViewRepresentable
#endif

/// This class receives delegate events since a struct can't be used for a delegate
class SwiftUIVideoViewDelegateReceiver: TrackDelegate {

    @Binding var dimensions: Dimensions?

    init(dimensions: Binding<Dimensions?> = .constant(nil)) {
        self._dimensions = dimensions
    }

    deinit {
        print("SwiftUIVideoViewDelegateReceiver deinit")
    }

    func track(_ track: VideoTrack,
               videoView: VideoView,
               didUpdate dimensions: Dimensions) {
        self.dimensions = dimensions
        print("SwiftUIVideoView got dimensions \(dimensions)")
    }

    func track(_ track: VideoTrack, videoView: VideoView, didUpdate size: CGSize) {
        print("SwiftUIVideoView got size \(size)")
    }
}

/// A ``VideoView`` that can be used in SwiftUI.
/// Supports both iOS and macOS.
struct SwiftUIVideoView: NativeViewRepresentable {
    /// Pass a ``VideoTrack`` of a ``Participant``.
    let track: VideoTrack
    let mode: VideoView.Mode
    @Binding var dimensions: Dimensions?

    let delegateReceiver: SwiftUIVideoViewDelegateReceiver

    init(_ track: VideoTrack,
         mode: VideoView.Mode = .fill,
         dimensions: Binding<Dimensions?> = .constant(nil)) {

        self.track = track
        self.mode = mode
        self._dimensions = dimensions

        print("SwiftUIVideoView adding delegate")
        self.delegateReceiver = SwiftUIVideoViewDelegateReceiver(dimensions: dimensions)
        self.track.add(delegate: delegateReceiver)
    }

    #if !os(macOS)
    // iOS

    func makeUIView(context: Context) -> VideoView {
        let view = VideoView()
        updateUIView(view, context: context)
        return view
    }

    func updateUIView(_ videoView: VideoView, context: Context) {
        videoView.track = track
        videoView.mode = mode
    }

    static func dismantleUIView(_ videoView: VideoView, coordinator: ()) {
        videoView.track = nil
    }
    #else
    // macOS

    func makeNSView(context: Context) -> VideoView {
        let view = VideoView()
        updateNSView(view, context: context)
        return view
    }

    func updateNSView(_ videoView: VideoView, context: Context) {
        videoView.track = track
        videoView.mode = mode
    }

    static func dismantleNSView(_ videoView: VideoView, coordinator: ()) {
        videoView.track = nil
    }

    #endif
}
