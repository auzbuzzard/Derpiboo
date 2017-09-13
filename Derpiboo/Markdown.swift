//
//  Markdown.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/1/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import Foundation

extension MarkdownParser {
    static let shared = MarkdownParser(font: .systemFont(ofSize: 17), color: Theme.colors().labelText, automaticLinkDetectionEnabled: false, customElements: [])
    
    func setup() {
        let imageLink = MarkdownImageLink(font: MarkdownParser.shared.font, color: .blue)
        
        //MarkdownParser.shared.addCustomElement()
    }
}

class MarkdownImageLink: MarkdownLink {
    override var regex: String {
        return "\\>\\>[\\d]+"
    }
}
