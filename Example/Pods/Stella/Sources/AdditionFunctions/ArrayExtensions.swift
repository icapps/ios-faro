//
//  AdditionFunctions.swift
//  Pods
//
//  Created by Stijn Willems on 16/11/2016.
//
//

import Foundation

// MARK: - ADD & DELETE without losing order

public extension Array where Element: Hashable {

    // MARK: - ADD

    /// Will add object to array if it is not in the array. Without losing the order of the first elements.
    /// - parameter elements: will be added to array if it is not yet contained in array
    /// - returns: true if elements are added
    @discardableResult
    public mutating func addIfNeeded(_ elements: inout [Element]) -> Bool {
        elements.uniq()
        var currentSet = Set<Element>(self)
        var elementSet = Set<Element>(elements)
        elementSet.subtract(currentSet)

        guard elementSet.count > 0 else {
            return false
        }

        if elementSet.count == elements.count {

            self.append(contentsOf: elements)
        } else {
            //What are the duplicates
            currentSet.subtract(elementSet)
            // remove them from objects
            let arrayToAppend = elements.filter {!currentSet.contains($0)}
            // append the remaining array
            self.append(contentsOf: arrayToAppend)
        }

        return true
    }

    /// Will add object to array if it is not in the array. Without losing the order of the first elements.
    /// - parameter element: will be added to array if it is not yet contained in array
    /// - returns: true if element is added
    @discardableResult
    public mutating func addIfNeeded(_ element: Element) -> Bool {
        var elements = [element]
        return addIfNeeded(&elements)
    }

    // MARK: - Delete

    /// Delete if the element is contained
    /// - parameter elements: will be deleted if contained
    /// - returns: true if element is deleted.
    @discardableResult
    public mutating func deleteIfNeeded(_ elements: [Element]) -> Bool {
        let currentSet = Set<Element>(self)
        let elementSet = Set<Element>(elements)
        let elementsToDelete = elementSet.intersection(currentSet)

        guard elementsToDelete.count > 0 else {
            return false
        }

        for element in elementsToDelete {
            if let index = self.index(of: element) {
                self.remove(at: index)
            }
        }

        return true
    }
    /// Delete if the element is contained
    /// - parameter element: will be deleted if contained
    /// - returns: true if element is deleted.
    @discardableResult
    public mutating func deleteIfNeeded(_ element: Element) -> Bool {
        return deleteIfNeeded([element])
    }

    mutating func uniq() {
        var added = Set<Element>(self)
        if added.count < self.count {
            let original = self
            self.removeAll()
            added.removeAll()
            for elem in original {
                if !added.contains(elem) {
                    self.append(elem)
                    added.insert(elem)
                }
            }
        }
    }
}
