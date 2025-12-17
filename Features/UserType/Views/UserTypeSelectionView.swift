//
//  AuthView.swift
//  Oryen
//
//  Created by Erick Maicon Lima de Almeida on 16/12/25.
//

import SwiftUI
import Lottie


enum UserType : String, CaseIterable {
    case cliente = "Cliente"
    case empresa = "Empresa"
}

struct UserTypeSelectionView: View {
    @State private var selectedType: UserType = .cliente
    
    var body: some View{
        ZStack{
            
        }
    }
}
