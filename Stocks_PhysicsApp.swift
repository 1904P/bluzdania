//
//  Stocks_PhysicsApp.swift
//  Stocks+Physics
//
// 
//
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            AssetInputView()
                .tabItem {
                    Label("Движение цены", systemImage: "chart.line.uptrend.xyaxis")
                }

            ContentView()
                .tabItem {
                    Label("Блуждания", systemImage: "waveform.path.ecg")
                }
        }
    }
}

@main
struct Stocks_PhysicsApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

#Preview {
    RootTabView()
}
