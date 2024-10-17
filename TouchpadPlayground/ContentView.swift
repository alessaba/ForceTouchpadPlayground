//
//  ContentView.swift
//  HapticMassage
//
//  Created by Alessandro Saba on 17/10/24.
//

import SwiftUI

struct ContentView : View {
	var body: some View {
		TabView{
			HapticMassage().tabItem{ Text("Massage") }
			ForceGauge().tabItem{ Text("Force Gauge") }
			TouchCanvas().tabItem{ Text("Touch Position") }
		}
	}
}

#Preview {
    ContentView()
}
