//
//  Scanner.swift
//  slox
//
//  Created by Peter Olsen on 1/1/20.
//  Copyright © 2020 Peter Olsen. All rights reserved.
//

import Foundation

/// Lexical scanner for Lox source.
class Scanner {
    /// Lox source code to scan.
    let source: String
    /// Tokens scanned from `source`.
    var tokens: [Token]
    /// Starting index in `source` for the token currently being scanned.
    var start: String.Index
    /// Current index being scanned in `source`.
    var current: String.Index
    /// Current line number in `source`.
    var line = 1
    
    static let keywords: [String: TokenType] = [
        "and": .AND,
        "class": .CLASS,
        "else": .ELSE,
        "false": .FALSE,
        "for": .FOR,
        "fun": .FUN,
        "if": .IF,
        "nil": .NIL,
        "or": .OR,
        "print": .PRINT,
        "return": .RETURN,
        "super": .SUPER,
        "this": .THIS,
        "true": .TRUE,
        "var": .VAR,
        "while": .WHILE
    ]
    
    /// Creates a Lox lexical scanner over the supplied source string.
    ///
    /// - Parameters:
    ///     - source: Lox source code to be scanned.
    init(source: String) {
        self.source = source
        start = source.startIndex
        current = source.startIndex
        tokens = []
    }
    
    /// Scans Lox source code and populates and returns the `tokens` array.
    ///
    /// - Returns:
    ///     Array of tokens scanned from the Lox source in `source`.
    func scanTokens() -> [Token] {
        while !isAtEnd {
            // We are at the start of the next lexeme.
            start = current
            scanToken()
        }
        tokens.append(Token(type: .EOF, lexeme: "", literal: nil, line: line))
        return tokens
    }
    
    /// A Boolean value indicating whether the current scanning position is at or beyond the end of the source string.
    var isAtEnd: Bool {
        current >= source.endIndex
    }
    
    /// Scan the next token and add it to `tokens`, ignoring comments and whitespace and counting lines.
    func scanToken() {
        let c = advance()
        switch c {
        case "(": addToken(type: .LEFT_PAREN)
        case ")": addToken(type: .RIGHT_PAREN)
        case "{": addToken(type: .LEFT_BRACE)
        case "}": addToken(type: .RIGHT_BRACE)
        case ",": addToken(type: .COMMA)
        case ".": addToken(type: .DOT)
        case "-": addToken(type: .MINUS)
        case "+": addToken(type: .PLUS)
        case ";": addToken(type: .SEMICOLON)
        case "*": addToken(type: .STAR)
        case "!": addToken(type: match("=") ? .BANG_EQUAL : .BANG)
        case "=": addToken(type: match("=") ? .EQUAL_EQUAL : .EQUAL)
        case "<": addToken(type: match("=") ? .LESS_EQUAL : .LESS)
        case ">": addToken(type: match("=") ? .GREATER_EQUAL : .GREATER)
        case "/":
            if match("/") {
                // It's a comment.
                while !peek().isNewline && !isAtEnd {
                    advance()
                }
            } else {
                addToken(type: .SLASH)
            }
        case let c where c.isNewline: line += 1
        case let c where c.isWhitespace : break    // must come after isNewline because newlines are whitespace
        case "\"": string()
        case let c where c.isAsciiDigit: number()
        case let l where l.isLetter || l == "_": identifier()
        default:
            error(line: line, message: "Unexpected character \"\(c)\"")
            break
        }
    }
    
    /// Returns the current character and advances the scanning position to the next character.
    ///
    /// - Returns:
    ///     The current character being scanned in `source`.
    @discardableResult
    func advance() -> Character {
        let currentChar = source[current]
        current = source.index(after: current)
        return currentChar
    }
    
    /// Adds a simple token to `tokens`.
    ///
    /// - Parameters:
    ///     - type: the `TokenType` of the token to add.
    func addToken(type: TokenType) {
        addToken(type: type, value: nil)
    }
    
    /// Adds a token to `tokens`.
    ///
    /// - Parameters:
    ///     - type: the `TokenType` of the token to add.
    ///     - value: the literal value, if any.
    func addToken(type: TokenType, value literal: Any?) {
        let text = String(source[start..<current])
        tokens.append(Token(type: type, lexeme: text, literal: literal, line: line))
    }
    
    /// Consume the next character if it matches the expected value.
    ///
    /// - Parameters:
    ///     - expected: the character expected
    /// - Returns:
    ///     `true` if the next character is equal to `expected`
    func match(_ expected: Character) -> Bool {
        if isAtEnd || source[current] != expected {
            return false
        }
        current = source.index(after: current)
        return true
    }
    
    /// Returns the current character without advancing the scanning position.
    ///
    /// - Returns:
    ///     The current character being scanned.
    func peek() -> Character {
        if isAtEnd {
            return "\0"
        }
        return source[current]
    }
    
    /// Returns the character after the current character without advancing the scanning position.
    ///
    /// - Returns:
    ///     The character after the current character being scanned.
    func peekNext() -> Character {
        if source.index(after: current) >= source.endIndex {
            return "\0"
        }
        return source[source.index(after: current)]
    }
    
    /// Adds a STRING token from the current position.
    func string() {
        while peek() != "\"" && !isAtEnd {
            if peek().isNewline {
                line += 1
            }
            advance()
        }
        if isAtEnd {
            error(line: line, message: "Unterminated string")
        }
        
        // Eat closing quote.
        advance()
        
        // Save string, without the surrounding quotes.
        let value = source[source.index(after: start)..<source.index(before: current)]
        addToken(type: .STRING, value: String(value))
    }
    
    /// Adds a NUMBER token from the current position.
    func number() {
        while peek().isAsciiDigit {
            advance()
        }
        if peek() == "." && peekNext().isAsciiDigit {
            advance()
        }
        while peek().isAsciiDigit {
            advance()
        }
        
        addToken(type: .NUMBER, value: Double(source[start..<current]))
    }
    
    /// Adds a keyword or an IDENTIFIER token from the current position.
    func identifier() {
        while peek().isAlphaNumeric {
            advance()
        }
        let text = String(source[start..<current])
        if let type = Self.keywords[text] {
            addToken(type: type)
        } else {
            addToken(type: .IDENTIFIER)
        }
    }
}

extension Character {
    /// A Boolean value indicating whether the character is an ASCII digit.
    var isAsciiDigit: Bool {
        self >= "0" && self <= "9"
    }
    
    /// A Boolean value indicating whether the character is a Unicode letter or number, or an underscore.
    var isAlphaNumeric: Bool {
        self.isLetter || self.isNumber || self == "_"
    }
}
