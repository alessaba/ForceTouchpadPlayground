//
//  TouchCanvas.swift
//  HapticMassage
//
//  Created by Alessandro Saba on 17/10/24
//  Code from Robert Vojta (https://gist.github.com/zrzka/224a18517649247a5867fbe65dbd5ae0)
//	Tweaks from Alessandro Saba

import SwiftUI
import AppKit

protocol AppKitTouchesViewDelegate: AnyObject {
	// Provides `.touching` touches only.
	func touchesView(_ view: AppKitTouchesView, didUpdateTouchingTouches touches: Set<NSTouch>)
}

final class AppKitTouchesView: NSView {
	weak var delegate: AppKitTouchesViewDelegate?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		// We're interested in `.indirect` touches only.
		allowedTouchTypes = [.indirect]
		// We'd like to receive resting touches as well.
		wantsRestingTouches = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func handleTouches(with event: NSEvent) {
		// Get all `.touching` touches only (includes `.began`, `.moved` & `.stationary`).
		let touches = event.touches(matching: .touching, in: self)
		// Forward them via delegate.
		delegate?.touchesView(self, didUpdateTouchingTouches: touches)
	}
	
	override func touchesBegan(with event: NSEvent) {handleTouches(with: event)}
	override func touchesMoved(with event: NSEvent) {handleTouches(with: event)}
	override func touchesEnded(with event: NSEvent) {handleTouches(with: event)}
	override func touchesCancelled(with event: NSEvent) {handleTouches(with: event)}
	
}

struct TouchesView: NSViewRepresentable {
	@Binding var touches: [Touch]
	
	func updateNSView(_ nsView: AppKitTouchesView, context: Context) {}
	
	func makeNSView(context: Context) -> AppKitTouchesView {
		let view = AppKitTouchesView()
		view.delegate = context.coordinator
		return view
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, AppKitTouchesViewDelegate {
		let parent: TouchesView
		
		init(_ view: TouchesView) {
			self.parent = view
		}
		
		func touchesView(_ view: AppKitTouchesView, didUpdateTouchingTouches touches: Set<NSTouch>) {
			parent.touches = touches.map(Touch.init)
		}
	}
}

struct Touch: Identifiable {
	// `Identifiable` -> `id` is required for `ForEach` (see below).
	let id: Int
	// Normalized touch X and Y position on a device (0.0 - 1.0).
	let normalizedX: CGFloat
	let normalizedY: CGFloat
	let type : UInt
	
	init(_ nsTouch: NSTouch) {
		// `NSTouch.normalizedPosition.y` is flipped -> 0.0 means bottom. But the
		// `Touch` structure is meants to be used with the SwiftUI -> flip it.
		self.id = nsTouch.hash
		self.normalizedX = nsTouch.normalizedPosition.x
		self.normalizedY = 1.0 - nsTouch.normalizedPosition.y
		self.type = nsTouch.phase
	}
}

/*
 let touchLoc = event.allTouches().first!.location(in: self.nsvi)
  print("\(touchLoc.position.x):\(touchLoc.y)")
 */

struct TouchCanvas: View {
	private let touchViewSize: CGFloat = 20
	private let touchColors: [Color] = [.green, .blue, .red, .yellow, .purple, .orange, .pink, .cyan, .brown, .mint, .black, .gray, .white]
	@State var touches: [Touch] = []
	
	var body: some View {
		ZStack {
			Text("Put fingers on the trackpad to see the relative position.")
				.opacity(self.touches.isEmpty ? 1 : 0)
				.animation(.easeOut, value: self.touches.isEmpty)
			
				
			GeometryReader { proxy in
				TouchesView(touches: self.$touches)
				
				ForEach(self.touches) { touch in
					//let indiceTocco = self.touches.firstIndex(where: { $0.id == touch.id })!
					Circle()
						.foregroundColor((touch.type == .began) ? touchColors[indiceTocco] : .accentColor)
						.opacity(0.8)
						.frame(width: self.touchViewSize, height: self.touchViewSize)
						.offset(
							x: proxy.size.width * touch.normalizedX - self.touchViewSize / 2.0,
							y: proxy.size.height * touch.normalizedY - self.touchViewSize / 2.0
						)
				}
			}
		}
	}
}
