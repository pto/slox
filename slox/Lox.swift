//
//  Lox.swift
//  slox
//
//  Created by Peter Olsen on 1/1/20.
//  Copyright © 2020 Peter Olsen. All rights reserved.
//

import Foundation

/// Executes the Lox program in the file.
///
/// - Parameters:
///   - _: file with Lox program to execute.
func runFile(_ path: String) {
    do {
        let src = try String(contentsOfFile: path)
        run(src)
        if hadError {
            exit(EX_DATAERR)
        }
    } catch let error {
        print(error.localizedDescription, to: &stderrOut)
        exit(EX_NOINPUT)
    }
}

/// Runs the Lox read-evaluate-print loop.
func runPrompt() {
    while true {
        print("> ", terminator: "")
        if let line = readLine() {
            run(line)
            hadError = false
        } else {
            print() // looks better in Terminal after ^D
            break
        }
    }
}

/// Executes the Lox program in the string.
///
/// - Note: May set `hadError` global variable.
///
/// - Parameters:
///   - _: string with Lox program to execute.
func run(_ source: String) {
    let scanner = Scanner(source: source)
    let tokens = scanner.scanTokens()
    for token in tokens {
        print(token)
    }
}

/// Reports a general error.
///
/// - Parameters:
///   - line: line number of the error.
///   - message: description of the error.
func error(line: Int, message: String) {
    report(line: line, at: "", message: message)
}

/// Prints an error message.
///
/// - Parameters:
///   - line: line number of the error.
///   - at: context of the error, beginning with a space.
///   - message: description of the error.
func report(line: Int, at: String, message: String) {
    print("[line \(line)] Error\(at): \(message)", to: &stderrOut)
    hadError = true
}
