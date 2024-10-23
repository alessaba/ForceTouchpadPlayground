//
//  HapticTunes.swift
//  TouchpadPlayground
//
//  Created by Alessandro Saba on 18/10/24.
//

//
//  ForceView.swift
//  HapticMassage
//
//  Created by Alessandro Saba on 17/10/24.
//

import SwiftUI
import AVFoundation
import AudioKit
import AudioKitUI

fileprivate let cid = CGSMainConnectionID()

class BeatDetectionEngine: ObservableObject {
	var engine = AudioEngine()      // Core AudioKit engine
	var player: AudioPlayer!        // Audio player
	var tap : AmplitudeTap!
	
	var fileURL : URL
	var threshold: Float
	@Published var isPlaying : Bool = false
	
	init(fileURL : URL, threshold: Float) {
		self.fileURL = fileURL
		self.threshold = threshold
		do {
			let file = try AVAudioFile(forReading: fileURL)
			player = AudioPlayer(file: file)
			engine.output = player
			
			// Set up amplitude tracking - Poi provare anche con FFTTap
			tap = AmplitudeTap(player) { amplitude in
				if amplitude > self.threshold {
					CGSActuateDeviceWithPattern(cid, 0, 0xf, 0) // Minima intensità, per ora. dopo provare con le intensità 0x1, 0x2
				}
				
				/*if amplitude > 0.2 && amplitude<0.3 {
					CGSActuateDeviceWithPattern(cid, 0, 0xf, 0) // Minima intensità, per ora. dopo provare con le intensità 0x1, 0x2
				} else if amplitude > 0.3{
					CGSActuateDeviceWithPattern(cid, 0, 0x1, 0)
				}*/
				//self.isPlaying = self.player.isPlaying
			}
			tap.start()
			
		} catch {
			print("Error loading audio file")
		}
	}
	
	func start() {
		do {
			try engine.start()
			player.play()
			self.isPlaying = true
		} catch {
			print("Error starting engine")
		}
	}
	
	func stop() {
		player.stop()
		engine.stop()
		self.isPlaying = false
	}
}


struct HapticTunes : View {
	@State var filePickerPresented : Bool = false
	@State var audioFileURL : URL = Bundle.main.url(forResource: "beat", withExtension: "aiff")!
	
	@State var beatEngine : BeatDetectionEngine?
	@State var threshold: Float = 0.2  // Adjust this threshold to detect beats
	
	@State var isPlaying: Bool = false
	
	var body: some View {
		VStack{
			Text(audioFileURL.lastPathComponent)
			// Uso .id(pickerPresented) per aggiornare la waveform quando cambio file
			AudioFileWaveform(url: $audioFileURL.wrappedValue).padding(.horizontal).tint(isPlaying ? .blue : .gray).frame(height: 200).id(filePickerPresented)
			
			//Gauge(value: threshold, in: 0...1){Text("")}.rotationEffect(.degrees(-90)).frame(width: 100) // Rappresentazione Threshold
			//Gauge(value: beatDetectionEngine?.player.currentPosition ?? 0, in: 0...1){Text("")} // Posizione traccia
			
			Slider(value: $threshold, in: 0.1...1, step: 0.1) {
				Text("Threshold: \(Int(threshold*100))%")
					.tint((threshold > 0.4) ? .orange : .primary)
			}.padding(.horizontal)
			
			Spacer()
			
			Button(isPlaying ? "􀜫 Stop" : "􀽎 Play") {
				if !isPlaying {
					beatEngine = BeatDetectionEngine(fileURL: audioFileURL, threshold: threshold)
					beatEngine!.start()
					isPlaying = true
					
					Timer.scheduledTimer(withTimeInterval: beatEngine!.player.duration, repeats: false){ timer in
						beatEngine!.stop()
						isPlaying = false
						timer.invalidate()
					}
				} else {
					beatEngine!.stop()
					isPlaying = false
				}
			}
			.tint(isPlaying ? .red : .green)
			.buttonStyle(.borderedProminent)
			
			Button("Custom Audio File...") {
				filePickerPresented.toggle()
			}
			
		}.padding()
		
		.onAppear {
			beatEngine = BeatDetectionEngine(fileURL: audioFileURL, threshold: threshold)
		}
		
		.fileImporter(isPresented: $filePickerPresented, allowedContentTypes: [.audio]){ result in
			switch result {
				case .success(let url):
					audioFileURL = url
				case .failure(let error):
					print("Error: \(error.localizedDescription)")
			}
		}
	}
}
