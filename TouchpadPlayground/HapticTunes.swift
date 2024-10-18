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
import AVFAudio

struct HapticTunes : View {
	@State var filePickerPresented : Bool = false
	var body: some View {
		VStack{
			Text("Work in Progress")
			Button("Pick Music File...") {
				filePickerPresented.toggle()
			}
		}.fileImporter(isPresented: $filePickerPresented, allowedContentTypes: [.audio]){ result in
			switch result {
				case .success(let text):
					print("Picked File at URL: \(text)")
				case .failure(let error):
					print("Error: \(error.localizedDescription)")
			}
			
		}
	}
}
