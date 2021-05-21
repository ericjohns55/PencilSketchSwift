//
//  ArrayUtility.swift
//  PencilSketch
//
//  Created by Eric Johns on 9/1/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//

import Foundation
import SwiftImage

class ArrayUtility {
    static func flipHorizontal(array: [[Int]]) -> [[Int]] {
        var arrayCopy: [[Int]] = array  // create a copy of array
        
        for y in 0..<(arrayCopy.count) {    // loop through all of y
            for x in 0..<(arrayCopy[0].count / 2) { // loop to half of x
                let placehold = arrayCopy[y][x] // hold pixel at y, x
                arrayCopy[y][x] = arrayCopy[y][arrayCopy[0].count - x - 1]  // set pixel at y, x to pixel at y, count - x - 1
                arrayCopy[y][arrayCopy[0].count - x - 1] = placehold    // set pixel at y, count - x - 1 to placehold
            }
        }
        
        return(arrayCopy)   // return array copy
    }
    
    static func flipVertical(array: [[Int]]) -> [[Int]] {
        var arrayCopy: [[Int]] = array  // create a copy of array
        
        for y in 0..<(arrayCopy.count / 2) {    // loop through half of y
            for x in 0..<(arrayCopy[0].count) { // loop through all of x
                let placehold = arrayCopy[y][x] // swap (y, x) with (height - y - 1, x) using a placeholder
                arrayCopy[y][x] = arrayCopy[arrayCopy.count - y - 1][x]
                arrayCopy[arrayCopy.count - y - 1][x] = placehold
            }
        }
        
        return(arrayCopy)
    }
    
    static func binary(image: Image<RGBA<UInt8>>) -> [[Int]] {
        print("Attempted")
        var array: [[Int]] = Array(repeating: Array(repeating: 0, count: image.width), count: image.height) // create copy of array
        
        for y in 0..<image.height { // loop through entire array
            for x in 0..<image.width {
                let red = Double(Int(image[x, y].red)) * 0.21   // use weighted average to convert to gray
                let green = Double(Int(image[x, y].green)) * 0.72
                let blue = Double(Int(image[x, y].blue)) * 0.07
                
                array[y][x] = (red + green + blue) > 127 ? 255 : 0  // if greater than 127, make it white, if less than, make it black
            }
        }
        
        return(array)
    }
    
    static func toIntArray(array: [[Double]]) -> [[Int]] {
        var intArray: [[Int]] = Array(repeating: Array(repeating: 0, count: array[0].count), count: array.count) // create int array
        
        for y in 0..<array.count {  // loop through entire array
            for x in 0..<array[0].count {
                intArray[y][x] = Int(array[y][x])   // cast double value into int
            }
        }
        
        return(intArray)
    }
    
    static func toDoubleArray(array: [[Int]]) -> [[Double]] {
        var doubleArray: [[Double]] = Array(repeating: Array(repeating: 0, count: array[0].count), count: array.count) // create double array
        
        for y in 0..<array.count {
            for x in 0..<array[0].count {
                doubleArray[y][x] = Double(array[y][x]) // cast int value to double
            }
        }
        
        return(doubleArray)
    }
    
    static func negate(array: [[Int]]) -> [[Int]] {
        var negated: [[Int]] = Array(repeating: Array(repeating: 0, count: array[0].count), count: array.count)
        
        for y in 0..<array.count {
            for x in 0..<array[0].count {
                negated[y][x] = 255 - array[y][x]   // set grayscale pixel to 255 - current value
            }
        }
        
        return(negated)
    }
    
    static func normalize(array: [[Int]]) -> [[Int]] {
        var normalized: [[Int]] = Array(repeating: Array(repeating: 0, count: array[0].count), count: array.count)
        var max = array[0][0], min = array[0][0] // declare a minimum and maximum value
        
        for y in 0..<array.count {
            for x in 0..<array[0].count {
                if (max < array[y][x]) {    // if max is less than current pixel
                    max = array[y][x]       // set max to current pixel
                } else if (min > array[y][x]) { // if min is greater than current pixel
                    min = array[y][x]           // set min to current pixel
                }
            }
        }
        
        for y in 0..<array.count {  // loop through entire array now that max and min were found
            for x in 0..<array[0].count {
                normalized[y][x] = Int((255.0 / Double(max - min)) * Double(array[y][x] - min)) // use formula 255 / (max - min) * pixel - min to put in range of 0 to 255
            }
        }
        
        return(normalized)
    }
    
    static func normalize(array: [[[Int]]]) -> [[[Int]]] {
        var normalized: [[[Int]]] = Array(repeating: Array(repeating: Array(repeating: 0, count: 3), count: array[0].count), count: array.count)
        
        for channel in 0..<3 {  // run normalization on each color channel
            var max = array[0][0][channel]  // declare min and max variables for each channel
            var min = array[0][0][channel]
            
            for i in 0..<array.count {
                for j in 0..<array[0].count {
                    if (array[i][j][channel] < min) {   // find new max and min and update if applicable
                        min = array[i][j][channel]
                    } else if (array[i][j][channel] - min > max) {
                        max = array[i][j][channel] - min
                    }
                }
            }
            
            for i in 0..<array.count {
                for j in 0..<array[0].count {
                    normalized[i][j][channel] = Int((255.0 / Double(max - min)) * Double(array[i][j][channel] - min))       // use normalization formula to put pixels in each color channel in 0-255 range
                }
            }
        }
        
        return(normalized)
    }
    
    static func copyRange(image1: inout [[Int]], copyTo: inout [[Int]], startX: Int, endX: Int, startY: Int, endY: Int, pasteX: Int, pasteY: Int) {
        var copyPortion: [[Int]] = Array(repeating: Array(repeating: 0, count: endX - startX), count: endY - startY)    // array to hold copy portion
        
        for y in startY..<endY {    // loop in range of start to end
            for x in startX..<endX {
                copyPortion[y - startY][x - startX] = image1[y][x]  // copy array into copy portion
            }
        }
        
        for y in pasteY..<min(copyPortion.count + pasteY, copyTo.count) {   // loop through paste portion
            for x in pasteX..<min(copyPortion[0].count + pasteX, copyTo[0].count) {
                copyTo[y][x] = copyPortion[y - pasteY][x - pasteX]  // overwrite copy portion into array
            }
        }
    }
    
    static func inBounds(i: Int, j: Int, y: Int, x: Int) -> Bool {
        var inBound: Bool = true    // default to true
        
        if (i < 0 || i >= y || j < 0 || j >= x) {   // check if in bounds of i-y and j-x
            inBound = false // set to false if not in range
        }
        
        return(inBound)
    }
    
    static func minimum(array: [[Int]]) -> Int {
        var minimum: Int = array[0][0]
        
        for y in 0..<(array.count) {    // loop through entire array
            for x in 0..<(array[0].count) {
                minimum = min(array[y][x], minimum) // update minimum if new minimum is found
            }
        }
        
        return(minimum) // return minimum
    }
    
    static func maximum(array: [[Int]]) -> Int {
        var maximum: Int = array[0][0]
        
        for y in 0..<(array.count) {    // loop through entire array
            for x in 0..<(array[0].count) {
                maximum = max(array[y][x], maximum) // update maximum if new maximum is found
            }
        }
        
        return(maximum) // return maximum
    }
}
