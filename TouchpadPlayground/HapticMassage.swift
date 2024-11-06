//
//  MassageView.swift
//  HapticMassage
//
//  Created by Alessandro Saba on 17/10/24.
//

import SwiftUI

fileprivate let cid = CGSMainConnectionID()

func colorforIntensity(_ intensity: Int) -> Color {
	switch intensity {
		case 0: return .green  			// Low
		case 1: return .orange 			// Medium
		case 2: return .red	   			// High
		default: return .accentColor 	// Fallback
	}
	
	//return [.green, .orange, .red][intensity] // We have no fallback this way and less comprehensible, but it's more compact. Not ideal
}

struct HapticMassage: View {
	@State var speed = 20.0
	@State var intensity : Int = 0
	@State var hoveringMassage: Bool = false
	
	var body: some View {
		VStack{
			HStack {
				Text("Intensity: ")
				Stepper("\(["Low  ", "Med ", "High"][Int(intensity)])", value: $intensity, in: 0...2)
					.padding(.vertical, 3)
					.padding(.horizontal, 10)
					.background(colorforIntensity(intensity).opacity(0.65))
					.clipShape(.capsule(style: .circular))
				
				Spacer()
				
				Slider(value: $speed, in: 5...100){
					Text("\(Int(speed)) Hz").bold()
				}
				.tint((speed > 75) ? .orange : .green )
				.frame(width: 300)
				
			}
			.padding()
			
			ZStack{
				Rectangle().fill(Color.gray.opacity(0.2))
					.onHover{_ in
						hoveringMassage.toggle()
						Timer.scheduledTimer(withTimeInterval: TimeInterval(1/speed), repeats: true){ timer in
							if hoveringMassage {
								// 8 valid pattern values are 0x1-0x6 and 0x0f-0x10 (1-6, 15, 16)
								CGSActuateDeviceWithPattern(cid, 0, [0xf, 0x1, 0x2][intensity], 0)
							} else {
								timer.invalidate()
							}
						}
					}
				
				Text("Place your fingers here to feel the massage").foregroundStyle(.secondary).opacity(hoveringMassage ? 0 : 1)
			}
		}
	}
}
