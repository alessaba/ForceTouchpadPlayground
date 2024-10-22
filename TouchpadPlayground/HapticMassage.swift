//
//  MassageView.swift
//  HapticMassage
//
//  Created by Alessandro Saba on 17/10/24.
//

import SwiftUI

fileprivate let cid = CGSMainConnectionID()

struct HapticMassage: View {
	@State var speed = 20.0
	@State var intensity : Int = 1
	@State var hoveringMassage: Bool = false
	
	var body: some View {
		VStack{
			HStack {
				Slider(value: $speed, in: 5...100){
					Text("Frequency: \(Int(speed)) Hz")
				}.tint((speed > 75) ? .red : .green )
				
				/*Slider(value: $intensity, in: 0...2, step: 1.0) {
					Text("Intensity: \(["Low ", "Med ", "High"][intensity])")
				}.padding(.horizontal)*/
				Stepper("Intensity: \(["Low ", "Med ", "High"][Int(intensity)])", value: $intensity, in: 0...2)
			}
			.padding()
			
			ZStack{
				Rectangle().fill(.gray)
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
				Text("Place your fingers here to feel the massage").foregroundStyle(.ultraThickMaterial).opacity(hoveringMassage ? 0 : 1)
				
			}
		}.frame(width: 500, height: 400)
	}
}
