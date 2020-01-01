//
//  Token.swift
//  slox
//
//  Created by Peter Olsen on 1/1/20.
//  Copyright © 2020 Peter Olsen. All rights reserved.
//

import Foundation

/// Details of a Lox token.
struct Token: CustomStringConvertible {
    /// The type of the token.
    let type: TokenType
    /// The lexeme of the token.
    let lexeme: String
    /// The literal value of the token.
    let literal: Any?
    /// The line number of the token.
    let line: Int

    /// A String representation of the token.
    var description: String {
        return "\(type) \(lexeme) \(String(describing: literal)) \(line)"
    }
}

/// Identifies the token type.
enum TokenType {
    // Single-character tokens.
    case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR

    // One or two character tokens.
    case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL

    // Literals.
    case IDENTIFIER, STRING, NUMBER

    // Keywords.
    case AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE

    case EOF
}
