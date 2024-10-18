//
//  MassageView.swift
//  HapticMassage
//
//  Created by Alessandro Saba on 17/10/24.
//

import SwiftUI

fileprivate let cid = CGSMainConnectionID()

func pattern(for intensity: Double) -> Int {
	// 8 valid pattern values are 0x1-0x6 and 0x0f-0x10
	switch intensity {
	case 0:
		return 15
	case 3:
		return 6
	default:
		return Int(intensity)
	}
}

struct HapticMassage: View {
	@State var speed = 20.0
	@State var intensity = 1.5
	@State var hoveringMassage: Bool = false
	@State var editingParameters: Bool = false
	
	var body: some View {
		VStack{
			HStack {
				Slider(value: $speed, in: 10...500){
					Text("Speed")
				}.tint((speed > 75) ? .red : .green )
				
				Slider(value: $intensity, in: 0...3){
					Text("Intensity")
				}.tint((intensity > 2) ? .red : .green )
			}
			.padding()
			ZStack{
				Rectangle().fill(.gray)
					.onHover{_ in
						hoveringMassage.toggle()
						Timer.scheduledTimer(withTimeInterval: TimeInterval(1/speed), repeats: true){ timer in
							if hoveringMassage {
								CGSActuateDeviceWithPattern(cid, 0, Int32(pattern(for: intensity)), 0);
							}
						}
					}
				Text("Place your fingers here to feel the massage").foregroundStyle(.ultraThickMaterial).opacity(hoveringMassage ? 0 : 1)
				
			}
		}.frame(width: 500, height: 400)
	}
}
