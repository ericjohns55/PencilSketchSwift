//
//  Sketch.swift
//  PencilSketch
//
//  Created by Eric Johns on 9/5/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//

import Foundation

class Sketch {
    //using the angle anf the dThresh values, lines are drawn tangent to the angle on the outline of the image with a rough appearance
    static func sketch(dThresh: [[Int]], gradAng: [[Double]], lineScale: Double) -> [[Int]] {
        var sketch: [[Int]] = Array(repeating: Array(repeating: 0, count: dThresh[0].count), count: dThresh.count)
        let height: Int = Int(sqrt(Double(sketch.count * sketch[0].count)) * lineScale)
        //using linescale, we find a suitable height based on the image size
        
        print("Starting sketch...")
        
        for y in 0..<sketch.count {
            for x in 0..<sketch[0].count {
                //anything >= 127 is either an edge, or maybe an edge. I have decided to get the maybe an edge as to simulate light strokes of
                //partially defined areas in an image. to make the actual edges stand out, the lines are drawn again on the edges.
                
                if (dThresh[y][x] >= 127) {
                    addLine(length: height, array: &sketch, ang: gradAng[y][x] + (Double.pi / 2), r: y, c: x)
                }
                
                if (dThresh[y][x] > 127) {
                    addLine(length: height, array: &sketch, ang: gradAng[y][x] + (Double.pi / 2), r: y, c: x)
                }
            }
        }
        
        print("Sketch complete")
        
        return(sketch)
    }
    
    //addLine simulates a stroke of a pencil on paper, using simple addition and a slope
    static func addLine(length: Int, array: inout [[Int]], ang: Double, r: Int, c: Int) {
        var lengthCopy = length
        
        if (lengthCopy % 2 == 0) {  //makes the line an odd number to have a set center for easy use
            lengthCopy += 1
        }
        
        var y: Int, x: Int
        let slope: Double = tan(ang)    //the slope ends up being the tangent to the gradient angle, making life easier
        
        if (abs(slope) >= 1 - 0.001) {  // handles slopes greater or equal to one
            for i in (-lengthCopy / 2)..<(lengthCopy / 2 + 1) {
                y = r + i
                x = c + Int(round(Double(i) / slope))
                //x and y are the coordinates to where the line should have something added
                
                //checks for boundaries, both on image and in line length
                if (x >= 0 && x < array[0].count && y >= 0 && y < array.count && sqrt(pow(Double(y - r), 2) + pow(Double(x - c), 2)) <= Double(lengthCopy / 2)) {
                    
                    array[y][x] += 1
                    
                    //add thickness, but making the line 2 pixels thick
                    if (x - 1 > 0) {
                        array[y][x - 1] += 1
                    }
                }
            }
        } else if (abs(slope) < 1) {    //very similar to the first part, just handeling slopes < 1
            for i in (-lengthCopy / 2)..<(lengthCopy / 2 + 1) {
                y = r + Int(round(Double(i) * slope))
                x = c + i
                
                if (x >= 0 && x < array[0].count && y >= 0 && y < array.count && sqrt(pow(Double(y - r), 2) + pow(Double(x - c), 2)) <= Double(lengthCopy / 2)) {
                    array[y][x] += 1
                    
                    if (y - 1 > 0) {
                        array[y - 1][x] += 1
                    }
                }
            }
        }
    }
    
    static func addSketch(gray: [[Double]], sketch: [[Int]]) -> [[Int]] {
        var newImage: [[Int]] = Array(repeating: Array(repeating: 0, count: sketch[0].count), count: sketch.count)
        var grayCopy: [[Int]] = ArrayUtility.toIntArray(array: gray)
        grayCopy = advNorm(array: &grayCopy, maxNew: 255, minNew: 8)    //makes the grayscale image normalized in a limited range to brighten blacks
        
        for i in 0..<(newImage.count) {
            for j in 0..<(newImage[0].count) {
                newImage[i][j] = grayCopy[i][j] - sketch[i][j]  //should make the places where the sketch marks are the darkest color
                
                if (newImage[i][j] < 0) {
                    newImage[i][j] = 0 //cuts off negative values
                }
            }
        }
        
        return(newImage)
    }
    
    static func addSketch(image: [[[Int]]], sketch: [[Int]]) -> [[[Int]]] {
        var newImage: [[[Int]]] = Array(repeating: Array(repeating: Array(repeating: 0, count: 3), count: sketch[0].count), count: sketch.count)    // makes new image
        
        for i in 0..<(newImage.count) {
            for j in 0..<(newImage[0].count) {
                for k in 0..<3 {
                    newImage[i][j][k] = image[i][j][k] - sketch[i][j]   //subtracts the pixel values of sketch from the original image
                    
                    if (newImage[i][j][k] < 0) {
                        newImage[i][j][k] = 0   //cuts of the negative values
                    }
                }
            }
        }
        
        return(newImage)
    }
    
    static func advNorm(array: inout [[Int]], maxNew: Int, minNew: Int) -> [[Int]] {
        let min = ArrayUtility.minimum(array: array)    // min value of the array
        let max = ArrayUtility.maximum(array: array)    // max value of the array
        
        for i in 0..<(array.count) {
            for j in 0..<(array[0].count) {
                array[i][j] = minNew + (array[i][j] - min) + (maxNew - minNew) / (max - min)    // normalization formula in inputted range
            }
        }
        
        return(array)
    }
    
    static func brightnessChange(rgb: [[[Int]]], multiplier: Double) -> [[[Int]]] {
        var newImage: [[[Int]]] = Array(repeating: Array(repeating: Array(repeating: 0, count: 3), count: rgb[0].count), count: rgb.count)
        var y: Double, u: Double, v: Double, r: Double, g: Double, b: Double
        
        for i in 0..<rgb.count {
            for j in 0..<rgb[0].count {
                r = Double(rgb[i][j][0]) / 255.0  //sets the rgb values to be a percentage
                g = Double(rgb[i][j][1]) / 255.0
                b = Double(rgb[i][j][2]) / 255.0
                y = (0.299 * r + 0.587 * g + 0.114 * b) * multiplier    //uses the formulas provided by wikipedia and a multiplier to make the image brighter
                u = -0.14713 * r - 0.28886 * g + 0.436 * b
                v = 0.615 * r - 0.51499 * g + 0.10001 * b
                newImage[i][j][0] = Int((y + 1.14 * v) * 255.0) //converts the yuv values back to rgb
                newImage[i][j][1] = Int((y - 0.396 * u - 0.581 * v) * 255.0)
                newImage[i][j][2] = Int((y + 2.033 * u) * 255.0)
            }
        }
        
        return(newImage)
    }
    
    static func sketch2(filtered: [[Double]], lineScale: Double, dThreshMin: Double, dThreshMax: Double) -> [[Int]] {
        //so basically this is detecting edges of the image and drawing lines tangent to the edge.
        var sine: Int, cosine: Int //used for parts of non maximum supresssion in finding corresponding points
        var r: Int, c: Int, u: Int, v: Int //other variables to loop through, r and c are used for a point, u and v are used for another
        var angle: Double //the gradients angle
        var maximum: Double, num1: Double, num2: Double, num3: Double //the values of the points being checked, each num holds a temporary point in the array for checking
        var maxNum: Double = 0 //maximum in the specified angle
        let x: Int = filtered[0].count - 1, y: Int = filtered.count - 1 //dimensions of the new image, being one pixel less on the right and bottom to account for the gradients decrease in the size
        var dThresh: [[Double]] = Array(repeating: Array(repeating: 0, count: x), count: y) //the array holding the new values to be used for threshholding
        var sketch: [[Int]] = Array(repeating: Array(repeating: 0, count: x), count: y)//the final array that represents the image with a skethed outline
        //looping through the entire picture, essentially doing all of edge detection at once at each pixel.
        for i in 0..<y {
            for j in 0..<x {
                angle = atan2(filtered[i + 1][j] - filtered[i][j], filtered[i][j + 1] - filtered[i][j])//the angle in which the gradient points
                angle = 0.25 * Double.pi * trunc(4.5 + (4 * angle / Double.pi))// the angle rebinned utilizing trig and truncation to narrow it to 4 segments, and 8 directions
                
                //used for supressing the non maximums along an angle
                sine = Int(round(sin(angle)))//narrows the sine of the angle to be -1, 0, or 1.
                cosine = Int(round(cos(angle)))//narrows the cosine of the angle to be -1, 0, or 1.
                //x and y are the coordinates for the point being tested
                //r and c are coordinates for a second point being tested
                //u and v are coordinates for the third point being tested, opposite of r and c.
                r = i + sine
                c = j + cosine
                u = i - sine
                v = j - cosine
                
                //the magnitude of the gradient, or change in color, of the image along the gradient at the point x,y
                num1 = sqrt(pow(filtered[i][j + 1] - filtered[i][j], 2) + pow(filtered[i + 1][j] - filtered[i][j], 2))
            
                //needs to check boundaries of other points being tested since it could potentiall be past the edge of the image.
                if (!ArrayUtility.inBounds(i: r, j: c, y: y, x: x)) {
                    r = i
                    c = j
                    num2 = num1 //if its off the edge of the image, make the second number of being checked equal to the first number.
                } else {
                    //if it is in bounds its the same calculation of num1, but at the point r,c
                    num2 = sqrt(pow(filtered[r][c + 1] - filtered[r][c], 2) + pow(filtered[r + 1][c] - filtered[r][c], 2))
                }
                
                //goes through same process of checking for boundaries like num2, but for the points u,v
                if (!ArrayUtility.inBounds(i: u, j: v, y: y, x: x)) {
                    u = i
                    v = j
                    num3 = num1
                } else {
                    num3 = sqrt(pow(filtered[u][v + 1] - filtered[u][v], 2) + pow(filtered[u + 1][v] - filtered[u][v], 2))
                }
                
                maximum = max(max(num1, num2), num3)//finds the maximum of the three points
                if (abs(num1 - maximum) < 0.0001) {//checking if the value at x,y is the maximum change and sets that for dThesh
                    dThresh[i][j] = maximum
                }

                if (maximum > maxNum) { // while the setup for double threshholding is undergoing, the maximum color change will also be recorded
                    maxNum = maximum
                }
            }
        }

        let height: Int = Int(sqrt(Double(sketch.count * sketch[0].count)) * lineScale) //sets up the length of the line for sketching, longer value makes the sketch rougher
        var thresh: Int = 0
        var slope: Double //slope of the line at sketching
        for i in 0..<y {
            for j in 0..<x {
                //sclaes the value at each point to be within the range of 0-255
                thresh = Int((255.0/maxNum) * dThresh[i][j])
                slope = atan2(filtered[i + 1][j] - filtered[i][j], filtered[i][j + 1] - filtered[i][j]) + (Double.pi / 2)
                //recalulates the angle from earlier and uses the tangent angle as the slope for the line to be added
                
                
                //dthresh was binned into three section dived by two values, the min and max.
                //if its in the middle, it means its gray area and it may be an edge. this is added into the sketch
                //to give a rough appearance and makes a general outline of edges.
                if (Double(thresh) >= dThreshMin) {
                    addLine(length: height, array: &sketch, ang: slope, r: i, c: j)
                }
                //if its in the confident area, meaning its theshold is greater than the maximum of of the middle section, its a true edge.
                //going over it again means it will darken the true edges and make a defined shape.
                if (Double(thresh) >= dThreshMax) {
                    addLine(length: height, array: &sketch, ang: slope, r: i, c: j)
                }
            }
        }

        return(sketch)
    }
}
