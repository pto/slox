//
//  main.swift
//  slox
//
//  Created by Peter Olsen on 12/31/19.
//  Copyright © 2019 Peter Olsen. All rights reserved.
//

import Foundation

/// Indicates whether an error occurred while running Lox.
var hadError = false

/// Implements a `TextOutputStream` over standardError.
struct StandardErrorOutputStream: TextOutputStream {
    func write(_ string: String) {
        FileHandle.standardError.write(Data(string.utf8))
    }
}

/// `StandardErrorOutputStream` for use in print statements.
var stderrOut = StandardErrorOutputStream()

/// Runs the program based on the arguments.
if CommandLine.arguments.count > 2 {
    print("Usage: slox [script]", to: &stderrOut)
    exit(EX_USAGE)
} else if CommandLine.arguments.count == 2 {
    runFile(CommandLine.arguments[1])
} else {
    runPrompt()
}
