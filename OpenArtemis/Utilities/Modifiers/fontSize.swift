//
//  fontSize.swift
//  OpenArtemis
//
//  Created by Igor Marcossi on 06/03/24.
//

import SwiftUI

extension View {
  func fontSize(_ size: CGFloat, _ weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
    self.font(.system(size: size, weight: weight, design: design))
    }
}
