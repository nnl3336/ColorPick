//
//  ContentView.swift
//  ColorPick
//
//  Created by Yuki Sasaki on 2025/03/01.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let colorPatterns: [[Color]] = [
        [.red, .blue, .yellow, .green, .pink],  // パターン1
        [.blue, .yellow, .green, .pink, .red],  // パターン2
        [.yellow, .green, .pink, .red, .blue],  // パターン3
        [.green, .pink, .red, .blue, .yellow],  // パターン4
        [.pink, .red, .blue, .yellow, .green],  // パターン5
    ]
    
    @State private var selectedPattern = 0
    
    var currentColors: [Color] {
        if selectedPattern == 5 {
            return (0..<5).map { _ in Color.random }
        } else {
            return colorPatterns[selectedPattern]
        }
    }
    
    var body: some View {
        VStack {
            Picker("パターンを選択", selection: $selectedPattern) {
                ForEach(0..<6, id: \.self) { index in
                    Text("パターン \(index + 1)").tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                ForEach(currentColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
