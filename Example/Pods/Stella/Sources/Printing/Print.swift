//
//  Dispatch.swift
//  Pods
//
//  Created by Jelle Vandebeeck on 06/06/16.
//
//

/**
 Writes the textual representations of items, prefixed with a 🍞 emoji, into the standard output.
 
 This textual representations is used for breadcrumbs.
 
 - Parameter items: The items to write to the output.
 */
public func printBreadcrumb(_ items: Any...) {
    print("🍞", items.map { String(describing: $0) }.joined(separator: " "))
}

/**
 Writes the textual representations of items, prefixed with a 🔥 emoji, into the standard output.
 
 This textual representations is used for errors.
 
 - Parameter items: The items to write to the output.
 */
public func printError(_ items: Any...) {
    print("🔥", items.map { String(describing: $0) }.joined(separator: " "))
}

/**
 Writes the textual representations of items, prefixed with a 🎯 emoji, into the standard output.
 
 This textual representations is used for user actions.
 
 - Parameter items: The items to write to the output.
 */
public func printAction(_ items: Any...) {
    print("🎯", items.map { String(describing: $0) }.joined(separator: " "))
}
