//
//  ContentView.swift
//  ColorPick
//
//  Created by Yuki Sasaki on 2025/03/01.
//

import SwiftUI
import CoreData

// 1. Enum を定義
enum ColorPattern: String, CaseIterable, Identifiable {
    case pattern1, pattern2, pattern3, pattern4, pattern5, random
    var id: String { self.rawValue }
    
    var colors: [Color] {
        switch self {
        case .pattern1: return [.red, .blue, .yellow, .green, .pink]
        case .pattern2: return [.blue, .yellow, .green, .pink, .red]
        case .pattern3: return [.yellow, .green, .pink, .red, .blue]
        case .pattern4: return [.green, .pink, .red, .blue, .yellow]
        case .pattern5: return [.pink, .red, .blue, .yellow, .green]
        case .random: return (0..<5).map { _ in Color.random }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: ColorPatternEntity.entity(), sortDescriptors: [])
    private var storedPatterns: FetchedResults<ColorPatternEntity>
    
    @State private var selectedPattern: ColorPattern = .pattern1
    @State private var selectedCircleIndex: Int? = nil
    
    var body: some View {
        VStack {
            // Pickerでパターン選択
            Picker("パターンを選択", selection: $selectedPattern) {
                ForEach(ColorPattern.allCases) { pattern in
                    Text(pattern.rawValue.capitalized).tag(pattern)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedPattern) { newValue in
                savePattern(newValue, selectedCircleIndex)
            }
            
            // Circle を表示
            HStack {
                ForEach(selectedPattern.colors.indices, id: \.self) { index in
                    Circle()
                        .fill(selectedPattern.colors[index])
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle().stroke(selectedCircleIndex == index ? Color.black : Color.clear, lineWidth: 3)
                        )
                        .onTapGesture {
                            selectedCircleIndex = (selectedCircleIndex == index) ? nil : index
                            savePattern(selectedPattern, selectedCircleIndex)
                        }
                }
            }
        }
        .onAppear {
            loadPattern()
        }
    }
    
    // 2. Core Data に保存（パターンと選択インデックス）
    private func savePattern(_ pattern: ColorPattern, _ index: Int?) {
        let entity = storedPatterns.first ?? ColorPatternEntity(context: viewContext)
        entity.selectedPattern = pattern.rawValue
        entity.selectedCircleIndex = Int16(index ?? -1)  // -1 は未選択の意味
        try? viewContext.save()
    }
    
    // 3. Core Data からロード
    private func loadPattern() {
        if let savedPattern = storedPatterns.first?.selectedPattern,
           let pattern = ColorPattern(rawValue: savedPattern) {
            selectedPattern = pattern
        }
        
        let savedIndex = Int(storedPatterns.first?.selectedCircleIndex ?? -1)
        selectedCircleIndex = savedIndex >= 0 ? savedIndex : nil
    }
}

// 4. Color のランダム拡張
extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
