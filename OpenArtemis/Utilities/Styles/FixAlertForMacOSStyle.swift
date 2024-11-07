//
//  FixStyle.swift
//  OpenArtemis
//
//  Created by Michael DiGovanni on 11/6/24.
//

import SwiftUI

/// Without this style, the Save button on MacOS alters is blue, with blue text when using a default action
/// Unsure why this works at all
struct FixAlertForMacOSStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}
