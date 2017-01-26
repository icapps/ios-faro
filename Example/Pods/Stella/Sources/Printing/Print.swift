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
 - Returns : text to be printed
 */
@discardableResult
public func printBreadcrumb(_ items: Any...) -> String? {
    guard Output.level == .verbose else {
        return nil
    }

    let text = "🍞 " + items.map { String(describing: $0) }.joined(separator: " ")
    print("\(text)")
    return text
}

/**
 Writes the textual representations of items, prefixed with a 🔥 emoji, into the standard output.

 This textual representations is used for errors.

 - Parameter items: The items to write to the output.
 - Returns : text to be printed
 */
@discardableResult
public func printError(_ items: Any...) -> String? {
    guard Output.level != .nothing || Output.level == .error else {
        return nil
    }
    let text = "🔥 " + items.map { String(describing: $0) }.joined(separator: " ")
    print(text)
    return text
}

/**
 Writes the textual representations of items, prefixed with a 🎯 emoji, into the standard output.

 This textual representations is used for user actions.

 - Parameter items: The items to write to the output.
 - Returns : text to be printed
 */
@discardableResult
public func printAction(_ items: Any...) -> String? {
    guard Output.level == .verbose || Output.level == .quiet else {
        return nil
    }
    let text = "🎯 " + items.map { String(describing: $0) }.joined(separator: " ")
    print("\(text)")
    return text
}

/**
 Writes the textual representations of items, prefixed with a 🤔 emoji, into the standard output.

 This textual representations is used for times when you want to log a text in conspicuous situations. Like when parsing and a key that is not obligatoiry is missing. You tell the developer:" You use my code but I think this is wrong."

 - Parameter items: The items to write to the output.
 - Returns : text to be printed
 */
@discardableResult
public func printQuestion(_ items: Any...) -> String? {
    guard Output.level == .verbose else {
        return nil
    }
    let text = "❓ " + items.map { String(describing: $0) }.joined(separator: " ")
    print("\(text)")
    return text
}
