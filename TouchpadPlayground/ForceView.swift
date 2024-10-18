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
	var body: some View {
		VStack{
			Slider(value: $pressure, in: 0...1){
				Text("Pressure")
			}.tint((pressure > 0.5) ? .red : .green )
			
			Text("\(String(format: "%.2f", pressure*100))%")
			
			Chart(pressHist){ elem in
				AreaMark(x: .value("Time", elem.time), y: .value("Pressure", elem.pressure))
					.interpolationMethod(.cardinal)
					.foregroundStyle(
						LinearGradient(gradient:
										Gradient(colors: [
											Color.accentColor.opacity(0.8),
											Color.accentColor.opacity(0.1)]),
									   startPoint: .top,
									   endPoint: .bottom))
				LineMark(x: .value("Time", elem.time), y: .value("Pressure", elem.pressure))
					.interpolationMethod(.cardinal)
					.symbol(.circle)
			}
		}
		.padding()
		.onAppear{
			NSEvent.addLocalMonitorForEvents(matching: .pressure){ event in
				pressure = event.pressure
				pressHist.append(Pressure(pressure: pressure, time: pressHist.count))
				return event
			}
		}
	}
}
