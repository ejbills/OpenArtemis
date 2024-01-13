//
//  HTML to MD.swift
//  OpenArtemis
//
//  Created by Ethan Bills on 1/13/24.
//

import SwiftSoup
import Foundation

class ArtemisHTML: HTML {
    var rawHTML: String
    var document: Document?
    var rawText: String = ""
    var markdown: String = ""
    var hasSpacedParagraph: Bool = false
    var isQuoteChild: Bool = false
    
    required init() {
        rawHTML = "Document not initialized correctly"
    }

    /// Converts the given node into valid Markdown by appending it onto the ``MastodonHTML/markdown`` property.
    /// - Parameter node: The node to convert
    func convertNode(_ node: Node) throws {
        if node.nodeName().starts(with: "h") {
            guard let last = node.nodeName().last else {
                return
            }
            guard let level = Int(String(last)) else {
                return
            }
            
            for _ in 0..<level {
                markdown += "#"
            }
            
            markdown += " "
            
            for node in node.getChildNodes() {
                try convertNode(node)
            }
            
            markdown += "\n\n"
            
            return
        } else if node.nodeName() == "p" {
            if hasSpacedParagraph {
                markdown += isQuoteChild ? "\n\n >" : "\n\n"
            } else {
                hasSpacedParagraph = true
            }
        } else if node.nodeName() == "br" {
            if hasSpacedParagraph {
                markdown += "\n"
            } else {
                hasSpacedParagraph = true
            }
        } else if node.nodeName() == "a" {
            markdown += "["
            for child in node.getChildNodes() {
                try convertNode(child)
            }
            markdown += "]"

            let href = try node.attr("href")
            markdown += "(\(href))"
            return
        } else if node.nodeName() == "strong" {
            markdown += "**"
            for child in node.getChildNodes() {
                try convertNode(child)
            }
            markdown += "**"
            return
        } else if node.nodeName() == "em" {
            markdown += "*"
            for child in node.getChildNodes() {
                try convertNode(child)
            }
            markdown += "*"
            return
        } else if node.nodeName() == "code" {
            markdown += "`"
            for child in node.getChildNodes() {
                try convertNode(child)
            }
            markdown += "`"
            return
        } else if node.nodeName() == "blockquote" {
            isQuoteChild = true
            for child in node.getChildNodes() {
                try convertNode(child)
            }
            isQuoteChild = false
            markdown += "\n\n"
            return

        } else if node.nodeName() == "pre", node.childNodeSize() >= 1 {
            if hasSpacedParagraph {
                markdown += "\n\n"
            } else {
                hasSpacedParagraph = true
            }

            let codeNode = node.childNode(0)
            
            if codeNode.nodeName() == "code" {
                markdown += "```"
                
                // Try and get the language from the code block

                if let codeClass = try? codeNode.attr("class"),
                   let match = try? #/lang.*-(\w+)/#.firstMatch(in: codeClass) {
                    // match.output.1 is equal to the second capture group.
                    let language = match.output.1
                    markdown += language + "\n"
                } else {
                    // Add the ending newline that we need to format this correctly.
                    markdown += "\n"
                }
                
                for child in codeNode.getChildNodes() {
                    try convertNode(child)
                }
                markdown += "\n```"
                return
            }
        }

        if node.nodeName() == "#text" && node.description != " " {
            markdown += node.description
        }

        for node in node.getChildNodes() {
            try convertNode(node)
        }
    }

}

protocol HTML {
    var rawHTML: String { get set }
    var document: Document? { get set }
    var rawText: String { get set }
    var markdown: String { get set }
    
    /// A default initalizer
    init()
    /// Initialize a Mastodon HTML instance
    /// - Parameter rawHTML: The Raw HTML from Mastodon
    init(rawHTML: String)
    
    /// Parse the document. This must be called before any other function in the document.
    mutating func parse() throws
    
    /// Retrieve the HTML document as a Markdown formatted string
    /// - Returns: A markdown formatted string of the document.
    mutating func asMarkdown() throws -> String
    
    /// Converts the given node into valid Markdown by appending it onto the ``HTML/markdown`` property.
    /// - Parameter node: The node to convert
    mutating func convertNode(_ node: Node) throws
}

extension HTML {
    init(rawHTML: String) {
        self.init()
        self.rawHTML = rawHTML
    }
    
    mutating func parse() throws {
        let doc = try SwiftSoup.parse(rawHTML)
        document = doc
        rawText = try doc.text()
    }
    
    mutating func asMarkdown() throws -> String {
        guard let document else {
            throw ConversionError.documentNotInitialized
        }

        markdown = ""

        guard let body: Node = document.body() else {
            return "Document Not Initialized"
        }
        try convertNode(body)

        return markdown
    }
}

/// An error that is presented during conversion
enum ConversionError: LocalizedError {
    case documentNotInitialized
    case bodyNotPresent
    
    public var errorDescription: String? {
        switch self {
        case .documentNotInitialized:
            return "The document was not properly initialized"
        case .bodyNotPresent:
            return "The document body was not available"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .documentNotInitialized:
            return "Make sure you are properly calling .parse()"
        case .bodyNotPresent:
            return "Makes sure you are using a proper HTML document."
        }
    }
}
