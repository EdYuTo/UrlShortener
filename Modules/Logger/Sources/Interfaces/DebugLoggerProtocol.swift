//
//  DebugLoggerProtocol.swift
//  DebugLogger
//
//  Created by Edson Yudi Toma.
//

public protocol DebugLoggerProtocol {
    func logInfo(_ message: String, args: CVarArg...)
    func logError(_ message: String, args: CVarArg...)
    func logWarning(_ message: String, args: CVarArg...)
}
