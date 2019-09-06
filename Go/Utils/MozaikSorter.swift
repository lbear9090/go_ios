//
//  MozaikSorter.swift
//  Go
//
//  Created by Lucky on 15/01/2018.
//  Copyright © 2018 Go. All rights reserved.
//

import Foundation

enum CellSize: Int, CustomStringConvertible {
    case small
    case medium
    case large
    
    var identifier: String {
        get {
            switch self {
            case .small:
                return "Small"
            case .medium:
                return "Medium"
            case .large:
                return "Large"
            }
        }
    }
    
    var description : String {
        switch self {
        case .small: return ".small";
        case .medium: return ".medium";
        case .large: return ".large";
        }
    }
}

class MozaikSorter: NSObject {
    
    //MARK: - Variables
    
    private let allSmallArray: [CellSize] = [.small, .small, .small]
    private let leftLargeArray: [CellSize] = [.large, .small, .small]
    private let rightLargeArray: [CellSize] = [.small, .large, .small]
    private let allMediumArray: [CellSize] = [.medium, .medium]
    
    private var array: [CellSize]!
    
    private var smallRowCount: Int = 0
    private var smallCellCount: Int!
    private var largeCellCount: Int!

    private var allowSmallRow: Bool {
        let availableSmallCount = smallCellCount - (smallRowCount * 3)
        return availableSmallCount > (largeCellCount * 2)
    }
    
    //MARK: - Public functions

    public func sortedArray(_ inputArray: [CellSize]) -> [CellSize] {
        self.array = inputArray
        self.smallCellCount = self.array.filter { $0 == .small }.count
        self.largeCellCount = self.array.filter { $0 == .large }.count
    
        traverseArray()
        return array
    }
    
    //MARK: - Private functions
    
    private func traverseArray(index: Int = 0) {
        var index = index
        
        //Grab 3 elements after index
        guard index+2 < self.array.endIndex else {
            return
        }
        let arraySlice = self.array[index...index+2]
        
        //Check if they already match a pattern
        if arraySlice.elementsEqual(allSmallArray) && allowSmallRow {
            index += 3
            // Keep track of rows where 3 smalls are used
            self.smallRowCount += 1
        } else if
            arraySlice.elementsEqual(leftLargeArray) ||
            arraySlice.elementsEqual(rightLargeArray) {
            index += 3
        }
        else if arraySlice.dropLast().elementsEqual(allMediumArray) {
            index += 2
        }
        else {
            //Rearrange to match a pattern
            matchPattern(from: index, with: arraySlice)
            return
        }
        traverseArray(index: index)
    }
    
    private func matchPattern(from index: Int, with rowElements: ArraySlice<CellSize>) {
        let followingElements = self.array.suffix(from: index+2)
        
        /* Check if first 2 elements match a pattern, then try to find 3rd matching element
         * from the remaining unsorted elements
         */
        if rowElements.dropLast().elementsEqual(allSmallArray.dropLast()) && allowSmallRow {
            performMatch(of: rowElements, to: allSmallArray, index: index, followingElements: followingElements)
            
        } else if rowElements.dropLast().elementsEqual(leftLargeArray.dropLast()) {
            performMatch(of: rowElements, to: leftLargeArray, index: index, followingElements: followingElements)

        } else if rowElements.dropLast().elementsEqual(rightLargeArray.dropLast()) {
            performMatch(of: rowElements, to: rightLargeArray, index: index, followingElements: followingElements)

        } else {
            
            //If first 2 don't match change second element to match a pattern
            if rowElements.first == .small {
                
                if let matchingIndex = followingElements.index(where: {
                    (allSmallArray[1] == $0 && allowSmallRow) || rightLargeArray[1] == $0
                }) {
                    self.array.insert(self.array.remove(at: matchingIndex), at: index+1)
                } else {
                    //If no element can be found, move incomplete row to end of collection
                    if let element = rowElements.first {
                        self.array.append(element)
                        self.array.remove(at: index)
                    }
                }
            } else if rowElements.first == leftLargeArray.first {
                
                if let matchingIndex = followingElements.index(where: { leftLargeArray[1] == $0 }) {
                    self.array.insert(self.array.remove(at: matchingIndex), at: index+1)
                } else {
                    //If no element can be found, move incomplete row to end of collection
                    if let element = rowElements.first {
                        self.array.append(element)
                        self.array.remove(at: index)
                    }
                }
            } else if rowElements.first == allMediumArray.first {
                
                if let matchingIndex = followingElements.index(where: { allMediumArray[1] == $0 }) {
                    self.array.insert(self.array.remove(at: matchingIndex), at: index+1)
                } else {
                    //If no element can be found, move incomplete row to end of collection
                    if let element = rowElements.first {
                        self.array.append(element)
                        self.array.remove(at: index)
                    }
                }
            }
        }
        traverseArray(index: index)
    }
    
    private func performMatch(of rowElements: ArraySlice<CellSize>, to pattern: [CellSize], index: Int, followingElements: ArraySlice<CellSize>) {
        if let matchingIndex = followingElements.index(where: { pattern.last == $0 }) {
            //Insert the element at the correct index to complete the pattern
            self.array.insert(self.array.remove(at: matchingIndex), at: index+2)
        } else {
            //If no element can be found, move incomplete row to end of collection
            self.array.append(contentsOf: rowElements)
            self.array.removeSubrange(index...index+2)
        }
    }
    
}
