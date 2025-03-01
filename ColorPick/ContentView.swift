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

class ColorSelectionViewModel: ObservableObject {
    @Published var selectedPattern: ColorPattern = .pattern1
    @Published var selectedCircleIndex: Int? = nil
    
    private let viewContext: NSManagedObjectContext
    private var storedPatterns: [ColorPatternEntity] = []  // 修正: 配列に変更
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        loadPattern()  // `storedPatterns` を `loadPattern` 内で取得
    }
    
    func savePattern() {
        if let entity = storedPatterns.first {
            entity.selectedPattern = selectedPattern.rawValue
            entity.selectedCircleIndex = Int16(selectedCircleIndex ?? -1)
        } else {
            let newEntity = ColorPatternEntity(context: viewContext)
            newEntity.selectedPattern = selectedPattern.rawValue
            newEntity.selectedCircleIndex = Int16(selectedCircleIndex ?? -1)
            storedPatterns.append(newEntity)  // 配列に追加
        }
        
        try? viewContext.save()
    }
    
    func loadPattern() {
        let fetchRequest: NSFetchRequest<ColorPatternEntity> = ColorPatternEntity.fetchRequest()
        if let results = try? viewContext.fetch(fetchRequest) {
            storedPatterns = results
            if let savedPattern = results.first?.selectedPattern,
               let pattern = ColorPattern(rawValue: savedPattern) {
                selectedPattern = pattern
            }
            let savedIndex = Int(results.first?.selectedCircleIndex ?? -1)
            selectedCircleIndex = savedIndex >= 0 ? savedIndex : nil
        }
    }
}

// 2. ContentView で ViewModel を使う
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel: ColorSelectionViewModel
    
    /*init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ColorSelectionViewModel(viewContext: viewContext))
    }*/
    
    var body: some View {
        VStack {
            // Pickerでパターン選択
            Picker("パターンを選択", selection: $viewModel.selectedPattern) {
                ForEach(ColorPattern.allCases) { pattern in
                    Text(pattern.rawValue.capitalized).tag(pattern)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: viewModel.selectedPattern) { _ in
                viewModel.savePattern()
            }
            
            // Circle を表示
            HStack {
                ForEach(viewModel.selectedPattern.colors.indices, id: \.self) { index in
                    Circle()
                        .fill(viewModel.selectedPattern.colors[index])
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle().stroke(viewModel.selectedCircleIndex == index ? Color.black : Color.clear, lineWidth: 3)
                        )
                        .onTapGesture {
                            viewModel.selectedCircleIndex = (viewModel.selectedCircleIndex == index) ? nil : index
                            viewModel.savePattern()
                        }
                }
            }
        }
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
