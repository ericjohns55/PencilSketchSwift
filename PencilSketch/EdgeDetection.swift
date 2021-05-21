//
//  EdgeDetection.swift
//  PencilSketch
//
//  Created by Eric Johns on 9/1/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//

import Foundation
import SwiftImage
import UIKit

class EdgeDetection {
    static func createBorder(kernel: Int, image: inout [[Int]]) -> [[Int]] {
        var borderReflected: [[Int]] = Array(repeating: Array(repeating: 0, count: image[0].count + (2 * kernel)), count: image.count + (2 * kernel))   // create new array that is 2 * kernel bigger in both directions
        var flipVertical: [[Int]] = ArrayUtility.flipVertical(array: image) // create vertically flipped copy
        
        ArrayUtility.copyRange(image1: &image, copyTo: &borderReflected, startX: 0, endX: image[0].count, startY: 0, endY: image.count, pasteX: kernel, pasteY: kernel) // copying image
        ArrayUtility.copyRange(image1: &flipVertical, copyTo: &borderReflected, startX: 0, endX: image[0].count, startY: image.count - kernel, endY: image.count, pasteX: kernel, pasteY: 0)    // copy top from flip vertical
        ArrayUtility.copyRange(image1: &flipVertical, copyTo: &borderReflected, startX: 0, endX: image[0].count, startY: 0, endY: kernel, pasteX: kernel, pasteY: borderReflected.count - kernel)   // copy bottom from flip vertical
        
        var flipHorizontal: [[Int]] = ArrayUtility.flipHorizontal(array: borderReflected)   // create horizontally flipped copy
        
        ArrayUtility.copyRange(image1: &flipHorizontal, copyTo: &borderReflected, startX: borderReflected[0].count - (kernel * 2), endX: borderReflected[0].count - kernel, startY: 0, endY: borderReflected.count, pasteX: 0, pasteY: 0)   // copy left left from flip horizontal
        ArrayUtility.copyRange(image1: &flipHorizontal, copyTo: &borderReflected, startX: kernel, endX: kernel * 2, startY: 0, endY: borderReflected.count, pasteX: borderReflected[0].count - kernel, pasteY: 0)   // copy right from flip horizontal
        
        print("Created border reflection")
        
        return(borderReflected)
    }
    
    static func createKernel(kernel: Int, sigma: Double) -> [[Double]] {
        var filter: [[Double]] = Array(repeating: Array(repeating: 0, count: (kernel * 2) + 1), count: (kernel * 2) + 1)    // create filter kernel with size 2 * kernel + 1
        let coefficient: Double = 1 / (2 * Double.pi * pow(sigma, 2))   // calculate coefficient of smoothing
        var sum: Double = 0 //sum of pixels in filter
        
        for u in -kernel..<(kernel + 1) {   // loop from -kernel to +kernel in both dimensions
            for v in -kernel..<(kernel + 1) {
                filter[u + kernel][v + kernel] = coefficient * exp(-(pow(Double(u), 2) + pow(Double(v), 2)) / Double(2 * pow(sigma, 2)))    // calculate gaussian value
                sum += filter[u + kernel][v + kernel]   // add value to sum
            }
        }
        
        for y in 0..<filter.count { // loop through entire filter
            for x in 0..<filter[0].count {
                filter[y][x] /= sum // divide by sum to get the weight
            }
        }
        
        print("Generated a \(kernel * 2 + 1)x\(kernel * 2 + 1) kernel with a sigma of \(sigma)")
        
        return(filter)
    }
    
    static func filter(kernel: [[Double]], image: [[Int]]) -> [[Double]] {
        let kernelSize: Int = kernel.count / 2  // calculate size of kernel
        var filteredImage: [[Double]] = Array(repeating: Array(repeating: 0, count: image[0].count - (2 * kernelSize)), count: image.count - (2 * kernelSize))  // create smaller array to account for border reflect
        
        print("Starting filter...")
        
        for y in kernelSize..<(image.count - kernelSize) {  // loop from k to height - k
            for x in (kernelSize..<image[0].count - kernelSize) {   // loop from k to width - k
                var counter: Double = 0
                
                for u in -kernelSize..<(kernelSize + 1) {   // loop through surrounding pixels in kernel, with the center point resting on the current image pixel
                    for v in -kernelSize..<(kernelSize + 1) {
                        counter += kernel[kernelSize + u][kernelSize + v] * Double(image[y + u][x + v]) // add the smoothing value
                    }
                }
                
                filteredImage[y - kernelSize][x - kernelSize] = counter // set smoothed pixel to counter
            }
        }
        
        print("Filter complete")
        
        return(filteredImage)
    }
    
    static func calcGradientX(image: [[Double]]) -> [[Double]] {
        var gradX: [[Double]] = Array(repeating: Array(repeating: 0, count: image[0].count - 1), count: image.count - 1)
        
        for y in 0..<(image.count - 1) {    // loop through all entire array except 1 pixel to prevent out of bounds
            for x in 0..<(image[0].count - 1) {
                gradX[y][x] = image[y][x + 1] - image[y][x] // calculate the gradient in the x dimension
            }
        }
        
        print("Gradient X generated")
        
        return(gradX)
    }
    
    static func calcGradientY(image: [[Double]]) -> [[Double]] {
        var gradY: [[Double]] = Array(repeating: Array(repeating: 0, count: image[0].count - 1), count: image.count - 1)
        
        for y in 0..<(image.count - 1) {    // loop through all entire array except 1 pixel to prevent out of bounds
            for x in 0..<(image[0].count - 1) {
                gradY[y][x] = image[y + 1][x] - image[y][x] // calculate the gradient in the y dimension
            }
        }
        
        print("Gradient Y generated")
        
        return(gradY)
    }
    
    static func calcGradMag(gradX: [[Double]], gradY: [[Double]]) -> [[Double]] {
        var gradMag: [[Double]] = Array(repeating: Array(repeating: 0, count: gradX[0].count), count: gradX.count)  // create array with the same size as the gradX and gradY
        
        for y in 0..<gradMag.count {    // loop through entire array
            for x in 0..<gradMag[0].count {
                gradMag[y][x] = sqrt(pow(gradX[y][x], 2) + pow(gradY[y][x], 2)) // calculate the grad magnitude using the root of gradX^2  + gradY^2
            }
        }
        
        print("Gradient magnitude calculated")
        
        return(gradMag)
    }
    
    static func calcGradAngle(gradX: [[Double]], gradY: [[Double]]) -> [[Double]] {
        var gradAngle: [[Double]] = Array(repeating: Array(repeating: 0, count: gradX[0].count), count: gradX.count)    // create an array to hold the angles at each pixel
        
        for y in 0..<gradAngle.count {  // loop through array
            for x in 0..<gradAngle[0].count {
                gradAngle[y][x] = atan2(gradY[y][x], gradX[y][x])   // use atan2 to calculate the angle between gradY and gradX
            }
        }
        
        print("Gradient angle calculated")
        
        return(gradAngle)
    }
    
    static func adjustGradAngle(gradAngle: inout [[Double]]) -> [[Int]] {
        var gradAngleAdj: [[Int]] = Array(repeating: Array(repeating: 0, count: gradAngle[0].count), count: gradAngle.count)    // create new array for binning angles
        
        for y in 0..<gradAngleAdj.count {   // loop through entire array
            for x in 0..<gradAngleAdj[0].count {
                if (gradAngle[y][x] < 0) {
                    gradAngle[y][x] += Double.pi    // add pi if the angle is negative
                }
                
                if (gradAngle[y][x] <= ((3 * Double.pi) / 4) + (Double.pi / 8) && gradAngle[y][x] >= ((3 * Double.pi) / 4) - (Double.pi / 8)) { // if angle is in range of 3pi/4 with a tolerance of pi/8, bin as 3
                    gradAngleAdj[y][x] = 3
                }  else if (gradAngle[y][x] <= (Double.pi / 2) + (Double.pi / 8) && gradAngle[y][x] >= (Double.pi / 2) - (Double.pi / 8)) { // if angle is in range of pi/2 with a tolerance of pi/8, bin as 2
                    gradAngleAdj[y][x] = 2
                } else if (gradAngle[y][x] <= (Double.pi / 4) + (Double.pi / 8) && gradAngle[y][x] >= (Double.pi / 4) - (Double.pi / 8)) { // if angle is in range of pi/4 with a tolerance of pi/8, bin as 1
                    gradAngleAdj[y][x] = 1
                } else if (gradAngle[y][x] <= Double.pi / 8 && gradAngle[y][x] >= (0 - (Double.pi / 8))) { // if angle is in range of 0 with a tolerance of pi/8, bin as o
                    gradAngleAdj[y][x] = 0
                } else { // if the angle was not binned make it 0
                    gradAngleAdj[y][x] = 0
                }
            }
        }
        
        print("Adjusted gradient angle")
        
        return(gradAngleAdj)
    }
    
    static func calcNonMaxSupp(gradMag: [[Double]], gradAngleAdj: [[Int]]) -> [[Double]] {
        var calcNonMaxSupp: [[Double]] = Array(repeating: Array(repeating: 0, count: gradMag[0].count), count: gradMag.count)   // create an array to thin out thick lines
        
        for y in 1..<(calcNonMaxSupp.count - 1) {   // loop through array with a border of one in each dimension to avoid out of bounds
            for x in 1..<(calcNonMaxSupp[0].count - 1) {
                switch (gradAngleAdj[y][x]) {
                    case 0:
                        if (gradMag[y][x] > gradMag[y][x - 1] && gradMag[y][x] > gradMag[y][x + 1]) {   // check if left and right pixels are less than current pixel
                            calcNonMaxSupp[y][x] = gradMag[y][x]
                        }
                        
                        break
                    case 1:
                        if (gradMag[y][x] > gradMag[y - 1][x - 1] && gradMag[y][x] > gradMag[y + 1][x + 1]) {   // check if top right and bottom left pixels are less than current pixel
                            calcNonMaxSupp[y][x] = gradMag[y][x]
                        }
                        
                        break
                    case 2:
                        if (gradMag[y][x] > gradMag[y - 1][x] && gradMag[y][x] > gradMag[y + 1][x]) {   // check if top and bottom pixels are less than current pixel
                            calcNonMaxSupp[y][x] = gradMag[y][x]
                        }
                        
                        break
                    case 3:
                        if (gradMag[y][x] > gradMag[y + 1][x - 1] && gradMag[y][x] > gradMag[y - 1][x + 1]) {   // check if bottom right and top left pixels are less than current pixel
                            calcNonMaxSupp[y][x] = gradMag[y][x]
                        }
                        
                        break
                    default: break
                }
            }
        }
        
        print("Excess pixels suppressed")
        
        return(calcNonMaxSupp)
    }
    
    static func doubleThresh(nonMaxSupp: [[Double]], min: Int, max: Int) -> [[Int]] {
        var doubleThresh: [[Int]] = Array(repeating: Array(repeating: 0, count: nonMaxSupp[0].count), count: nonMaxSupp.count) // create new array to copy values within the threshold into
        
        for y in 0..<nonMaxSupp.count { // loop through entire array
            for x in 0..<nonMaxSupp[0].count {
                if (nonMaxSupp[y][x] > Double(max)) {   //  if the current pixel is greater than the max
                    doubleThresh[y][x] = 255    // make the edge white
                } else if (nonMaxSupp[y][x] <= Double(max) && nonMaxSupp[y][x] >= Double(min)) {    // if it is between max and min, it is a possible edge, make it 127
                    doubleThresh[y][x] = 127
                }
            }
        }
        
        print("Comparing pixels to thresholds")
        
        return(doubleThresh)
    }
    
    static func calcEdge(doubleThresh: [[Int]]) -> [[Int]] {
        var calcEdge: [[Int]] = Array(repeating: Array(repeating: 0, count: doubleThresh[0].count), count: doubleThresh.count)  // make array for final edge detected value
        
        for y in 1..<(calcEdge.count - 1) { // loop through array with 1 pixel padding to prevent out of bounds error
            for x in 1..<(calcEdge[0].count - 1) {
                if (doubleThresh[y][x] == 127) {    // check if the pixel is 127 (possible edge)
                    for i in -1..<2 {   // loop through the immediately surrounding pixels on all sides
                        for j in -1..<2 {
                            if (doubleThresh[y + i][x + j] == 255) {    // if any surrounding pixels are 255, make this pixel 255 as well, it is an edge
                                calcEdge[y][x] = 255
                            }   // otherwise it is not an edge, keep it 0
                        }
                    }
                } else if (doubleThresh[y][x] == 255) {
                    calcEdge[y][x] = 255    // keep it as an edge if it already is one
                }
            }
        }
        
        print("Calculating final edge")
        
        return(removeFinalBorder(calcEdge: calcEdge))   // remove the final 1 pixel border in each side
    }
    
    private static func removeFinalBorder(calcEdge: [[Int]]) -> [[Int]] {
        var finalImage: [[Int]] = Array(repeating: Array(repeating: 0, count: calcEdge[0].count - 2), count: calcEdge.count - 2)    // create new array that is 2 pixels shorter on each side
        
        for y in 1..<(calcEdge.count - 1) { // loop from 1 to size - 1 in each dimension
            for x in 1..<(calcEdge[0].count - 1) {
                finalImage[y - 1][x - 1] = calcEdge[y][x]   // copy final edge image into new array
            }
        }
        
        print("Removing final border")
        
        return(finalImage)
    }
}
