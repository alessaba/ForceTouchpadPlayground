//
//  ForceView.swift
//  HapticMassage
//
//  Created by Alessandro Saba on 17/10/24.
//

import SwiftUI
import Charts

struct Pressure: Identifiable, Equatable {
	var pressure: Float
	var time: Int
	var id: UUID = UUID()
}

struct ForceGauge : View {
	@State var pressure: Float = 0.0
	@State var pressHist : [Pressure] = []
	@State var deepPress : Bool = false
	@State var avgPressure: Float = 0.0
	
	var body: some View {
		VStack{
			Gauge(value: pressure) {
				Text("Pressure")
			} currentValueLabel: {
				Text("\(String(format: "%.2f", pressure*100))%")
			}
			.tint((deepPress) ? .red : .green )
			
			Spacer()
			
			Gauge(value: avgPressure) {
				Text("Average - 25 Samples")
			} currentValueLabel: {
				Text("\(String(format: "%.2f", avgPressure*100))%")
			}.tint(.purple)
			
			Chart(pressHist){ elem in
				AreaMark(x: .value("Time", elem.time), y: .value("Pressure", elem.pressure))
					.interpolationMethod(.cardinal)
					.foregroundStyle(
						LinearGradient(gradient:
										Gradient(colors: [.accentColor.opacity(0.8), .accentColor.opacity(0.1)]),
									   startPoint: .top,
									   endPoint: .bottom)
					)
				
				LineMark(x: .value("Time", elem.time), y: .value("Pressure", elem.pressure))
					.interpolationMethod(.cardinal)
				
			}.chartLegend(.hidden)
		}
		.padding()
		.onAppear{
			NSEvent.addLocalMonitorForEvents(matching: .pressure){ event in
				pressure = event.pressure
				
				// Aggiungi il nuovo valore alla storia
				pressHist.append(Pressure(pressure: pressure, time: pressHist.count))
				
				// Calcola la media mobile per gli ultimi 25 valori
				let lastTwentyFiveValues = pressHist.map(\.pressure).suffix(25)
				avgPressure = lastTwentyFiveValues.reduce(0, +) / Float(lastTwentyFiveValues.count)
				
				// Riconosci la transizione verso deepPress e normalPress
				if riconosciTransizione(hist: lastTwentyFiveValues.dropLast(), soglia: 0.8) {
					deepPress = true
					print("DeepPress:1")
				} else if riconosciTransizione(hist: lastTwentyFiveValues.dropLast(), soglia: 0.25) && deepPress {
					deepPress = false
					print("DeepPress:0")
				}
				
				//if (pressHist.last?.pressure ?? 0 > pressure) {deepPress = true} else {deepPress=false} // Throttle/Brake style
				
				return event
			}
		}
	}
}

// Experimenting on how to recognize when the user deep presses to 
func riconosciTransizione(hist: [Float], soglia: Float) -> Bool {
	let lenArray = hist.count
	if lenArray < 10 { return false }
	
	let ultimoValore = hist[lenArray-3]
	let penultimoValore = hist[lenArray-5]
	let differenza = ultimoValore - penultimoValore
	
	// Verifica che il cambiamento superi la soglia
	if abs(differenza) > soglia {
		return true
	}
	
	return false
}
