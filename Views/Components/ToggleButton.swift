//
//  ToggleButton.swift
//  Oryen
//
//  Created by Erick Maicon Lima de Almeida on 16/12/25.
//

import SwiftUI

struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color("Cor Botão") : Color.clear)
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
