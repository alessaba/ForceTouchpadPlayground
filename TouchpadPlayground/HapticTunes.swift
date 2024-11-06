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
	@State var currentTime: TimeInterval = 0
	
	var body: some View {
		VStack{
			Button(audioFileURL.lastPathComponent) {filePickerPresented.toggle()}
				.clipShape(.capsule)
				.padding(.vertical)
			
			// Posizione traccia. Inizio da -0 per evitare warning UX
			Gauge(value: currentTime, in: -0...(beatEngine?.player.duration ?? 1)){Text("")}
				.id(filePickerPresented) // Aggiorna durata
				.animation(.smooth, value: currentTime)
				.tint(.accentColor)
				.padding(.horizontal)
				.onAppear{
					Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){ timer in
						if (isPlaying){
							currentTime += 0.05
							if !isPlaying{ timer.invalidate() }
						}
					}
				}
			
			Button(isPlaying ? "􀜫 Stop" : "􀽎 Play") {
				if !isPlaying {
					beatEngine = BeatDetectionEngine(fileURL: audioFileURL, threshold: threshold)
					beatEngine!.start()
					isPlaying = true
					
					// Quando finisce il file, ferma la riproduzione
					Timer.scheduledTimer(withTimeInterval: beatEngine!.player.duration, repeats: false){ timer in
						beatEngine!.stop()
						isPlaying = false
						currentTime = 0
						timer.invalidate()
					}
				} else {
					beatEngine!.stop()
					isPlaying = false
				}
			}
			.tint(isPlaying ? .red : .green)
			.buttonStyle(.borderedProminent)
			
			ZStack{
				// Uso .id(pickerPresented) per aggiornare la waveform quando cambio file
				AudioFileWaveform(url: $audioFileURL.wrappedValue).padding(.horizontal).id(filePickerPresented).foregroundStyle(isPlaying ? .blue : .gray)
			}

			//Gauge(value: threshold, in: 0...1){Text("")}.rotationEffect(.degrees(-90)).frame(width: 100) // Rappresentazione Threshold
			
			
			
			Slider(value: $threshold, in: 0.1...1, step: 0.05) {
				Text("Threshold: \(Int(threshold*100))%")
			}
			.foregroundStyle((threshold > 0.4) ? .orange : .primary)
			.padding()
			
		}
		
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
