//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class Markdown {
    struct Rule {
        let name: String
        let delimiter: [String]
        let regex: NSRegularExpression
        let ruleOptions: RuleOptions
        
        var importance: UInt
        
        init(name: String, delimiter: [String], regex: String, importance: UInt = 1, ruleOptions: RuleOptions) throws {
            self.name = name
            self.delimiter = delimiter
            do {
                self.regex = try NSRegularExpression(pattern: regex, options: .useUnicodeWordBoundaries)
            } catch {
                throw error
            }
            self.importance = importance
            self.ruleOptions = ruleOptions
        }
    }
    
    struct RuleOptions {
        let attributes: [NSAttributedStringKey: Any?]
        let customProcedures: ((_ matchedString: String) -> Void)?
    }
    
    func parse(input: String, rules: [Rule]) -> NSAttributedString {
        var attrString = NSMutableAttributedString(string: input, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)])
        let _ = rules.map { rule in
            let group = rule.regex.matches(in: attrString.string, options: [], range: NSRange(location: 0, length: input.count))
            for item in group {
                let string = (input as NSString).substring(with: item.range)
                var strippedString = string
                for delimiter in rule.delimiter {
                    strippedString = strippedString.replacingOccurrences(of: delimiter, with: "")
                }
                
                print("\(rule.name): \(strippedString)")
                attrString.replaceCharacters(in: item.range, with: NSAttributedString(string: strippedString))
                
                format(string: &attrString, atRange: item.range, withRules: rule.ruleOptions)
            }
        }
        return attrString
    }
    
    func format(string: inout NSMutableAttributedString, atRange range: NSRange, withRules rules: RuleOptions) {
        string.addAttributes(rules.attributes, range: range)
    }
    
}


let text = "The *quick* _brown_ [spoiler]fox[/spoiler] +jumped+ _over *the* lazy dog_. >>123456 here's a pic."
let text2 = "*bold* _italics_"

let rules = [
    try! Markdown.Rule(name: "bold", delimiter: ["*"], regex: "()(\\*)(.+?)(\\2)", ruleOptions:
        Markdown.RuleOptions(attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor:UIColor.blue], customProcedures: nil)
    ) ,
    try! Markdown.Rule(name: "italics", delimiter: ["_"], regex: "()(\\_)(.+?)(\\2)", ruleOptions:
        Markdown.RuleOptions(attributes: [NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 12)], customProcedures: nil)
    ) ,
    try! Markdown.Rule(name: "underline", delimiter: ["+"], regex: "\\+.+\\+", ruleOptions:
        Markdown.RuleOptions(attributes: [NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 17)], customProcedures: nil)
    ) ,
    try! Markdown.Rule(name: "strikethrough", delimiter: ["-"], regex: "\\-.+\\-", ruleOptions:
        Markdown.RuleOptions(attributes: [NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 17)], customProcedures: nil)
    ) ,
    try! Markdown.Rule(name: "spoiler", delimiter: ["[spoiler]","[/spoiler]"], regex: "(\\[spoiler\\]).+(\\[\\/spoiler\\])", ruleOptions:
        Markdown.RuleOptions(attributes: [NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 17)], customProcedures: nil)
    ) ,
    try! Markdown.Rule(name: "DBImage", delimiter: [">>"], regex: "\\>\\>[\\d]+", ruleOptions:
        Markdown.RuleOptions(attributes: [NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 17)], customProcedures: nil)
    )
]

Markdown().parse(input: text2, rules: rules)







