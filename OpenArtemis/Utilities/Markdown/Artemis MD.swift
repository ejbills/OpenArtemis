//
//  Winston MD.swift
//  winston
//
//  Created by Ethan Bills on 1/12/24.
//

import SwiftUI
import MarkdownUI

extension Theme {
    /// Winston Markdown theme.
    public static func artemisMarkdown(fontSize: CGFloat, lineSpacing: CGFloat = 0.2) -> Theme {
        let theme = Theme()
            .text {
                FontSize(fontSize)
            }
            .paragraph { configuration in
                configuration.label
                    .lineSpacing(lineSpacing)
            }
            .heading1 { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontSize(fontSize * 2)
                    }
            }
            .heading2 { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontSize(fontSize * 1.5)
                    }
            }
            .heading3 { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontSize(fontSize * 1.25)
                    }
            }
            .listItem { configuration in
                configuration.label
                    .markdownMargin(top: .em(0.3))
            }
            .codeBlock { configuration in
                configuration.label
                    .markdownTextStyle {
                        FontSize(.em(0.85))
                        FontFamilyVariant(.monospaced)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .markdownMargin(top: .zero, bottom: .em(0.8))
            }
            .table { configuration in
                ScrollView (.horizontal) {
                    configuration.label
                        .fixedSize(horizontal: false, vertical: true)
                        .markdownTableBackgroundStyle(
                            .alternatingRows(Color(.systemBackground), Color(.secondarySystemBackground))
                        )
                        .markdownMargin(top: 0, bottom: 16)
                }
            }
            .tableCell { configuration in
                configuration.label
                    .markdownTextStyle {
                        if configuration.row == 0 {
                            FontWeight(.semibold)
                        }
                        BackgroundColor(nil)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .relativeLineSpacing(.em(0.25))
            }
            .blockquote { configuration in
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(rgba: 0x4244_4eff))
                        .relativeFrame(width: .em(0.2))
                    configuration.label
                        .markdownTextStyle { ForegroundColor(Color(rgba: 0x9294_a0ff)) }
                        .relativePadding(.horizontal, length: .em(1))
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        return theme
    }
}
