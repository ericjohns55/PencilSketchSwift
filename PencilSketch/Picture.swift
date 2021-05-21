//
//  Picture.swift
//  PencilSketch
//
//  Created by Eric Johns on 8/28/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//

import UIKit
import Foundation
import SwiftImage

class Picture {
    var image: Image<RGBA<UInt8>>   // main image variable that is manipulated through entire class
    
    init() {
        image = Image<RGBA<UInt8>>(named: "townhall")!  // set townhall to default image
    }
    
    init(name: String) {
        image = Image<RGBA<UInt8>>(named: name)!        // load image from resources with name
    }
    
    init(image: Image<RGBA<UInt8>>) {
        self.image = image                              // set image to another pre-made image
    }
    
    init(width: Int, height: Int) {
        image = Image<RGBA<UInt8>>(width: width, height: height, pixel: .black) // create an all black image with a declared width and height
    }
    
    init(array: [[Double]]) {
        image = Image<RGBA<UInt8>>(width: array[0].count, height: array.count, pixel: .black)   // create new image with array width and height
        
        for y in 0..<array.count {          // loop through entire array
            for x in 0..<array[0].count {
                image[x, y] = RGBA(red: UInt8(array[y][x]), green: UInt8(array[y][x]), blue: UInt8(array[y][x]), alpha: UInt8(255)) // load value into all color channels since the image is grayscale
            }
        }
    }
    
    init(array: [[Int]]) {
        image = Image<RGBA<UInt8>>(width: array[0].count, height: array.count, pixel: .black)   // create new image with array width and height

        for y in 0..<array.count {
            for x in 0..<array[0].count {
                image[x, y] = RGBA(red: UInt8(array[y][x]), green: UInt8(array[y][x]), blue: UInt8(array[y][x]), alpha: UInt8(255)) // load value into all color channels since the image is grayscale
            }
        }
    }
    
    func getHeight() -> Int {
        return image.height // return height
    }
    
    func getWidth() -> Int {
        return image.width  // return width
    }
    
    func getImage() -> Image<RGBA<UInt8>> {
        return image    // return image
    }
    
    func getUIImage() -> UIImage {
        return image.uiImage    // return image as a UIImage
    }
    
    func setPicture(name: String) {
        image = Image<RGBA<UInt8>>(named: name)!    // set picture to an image from resources with name
    }
    
    func setPicture(image: Image<RGBA<UInt8>>) {
        self.image = image                          // set image to a pre-made image
    }
    
    func setPicture(image: UIImage) {
        self.image = Image<RGBA<UInt8>>(uiImage: image) // set image to a UIImage
    }
    
    func getPixel(x: Int, y: Int) -> RGBA<UInt8> {
        return image.pixelAt(x: x, y: y)!       // return pixel at coordinates (x, y)
    }
    
    func setArray(array: [[Int]]) {
        image = Image<RGBA<UInt8>>(width: array[0].count, height: array.count, pixel: .black)   // set image to a new black image with the same dimensions as array
        
        for y in 0..<array.count {
            for x in 0..<array[0].count {
                image[x, y] = RGBA(red: UInt8(array[y][x]), green: UInt8(array[y][x]), blue: UInt8(array[y][x]), alpha: UInt8(255)) // load value into all color channels since the image is grayscale
            }
        }
    }
    
    func setArray(array: [[[Int]]]) {
        image = Image<RGBA<UInt8>>(width: array[0].count, height: array.count, pixel: .black)   // set image to a new black image with the same dimensions as array
        
        for y in 0..<array.count {
            for x in 0..<array[0].count {
                image[x, y] = RGBA(red: UInt8(array[y][x][0]), green: UInt8(array[y][x][1]), blue: UInt8(array[y][x][2]), alpha: UInt8(255))    // load all color values into the appropriate color channel
            }
        }
    }
    
    func rotate(degrees: Int) {
        image = image.rotated(byDegrees: degrees)   // rotate image to inputted degrees
    }
    
    func resize(factor: Double) {
        let newWidth: Int = Int(Double(getWidth()) * factor)    // calculate new height and width using the factor
        let newHeight: Int = Int(Double(getHeight()) * factor)
        
        image = image.resizedTo(width: newWidth, height: newHeight) // resize the image to the new width and height
    }
    
    func resizeExact(width: Int, height: Int) {
        image = image.resizedTo(width: width, height: height)   // resize image to inputted width and height
    }
    
    func convertToGray() {
        for index in 0..<(image.width * image.height) { // loop through image in one direction: it is faster than looping in two
            let y = index % image.height    // the y coordinate is equal to the index mod the height
            let x = index / image.height    // the x coordinate is equal to the index divided by the height
            
            let red = Double(image.pixelAt(x: x, y: y)!.red) * 0.21     // use a weighted average to calculate gray value
            let green = Double(image.pixelAt(x: x, y: y)!.green) * 0.72
            let blue = Double(image.pixelAt(x: x, y: y)!.blue) * 0.07
            let alpha = image.pixelAt(x: x, y: y)!.alpha
            
            let gray = UInt8(red + green + blue)    // gray equal all the weights added together
            
            image[x, y] = RGBA(red: gray, green: gray, blue: gray, alpha: alpha)    // load gray value into all channels
        }
    }
    
    func squareImage() {
        if (image.width != image.height) {  // check that the image is already not a square
            var slice: ImageSlice<RGBA<UInt8>>
            let width = image.width % 2 == 0 ? image.width : image.width - 1    // make the width and height an even number so it divides evenly
            let height = image.height % 2 == 0 ? image.height : image.height - 1
            
            if (width > image.height) {         // if the width is greater
                let cropOut = (width - height) / 2
                slice = image[cropOut..<(width - cropOut), 0..<height]  // crop to middle square
            } else {
                let cropOut = (height - width) / 2  // if the height is greater
                slice = image[0..<width, cropOut..<(height - cropOut)]  // crop to middle square
            }
            
            image = Image<RGBA<UInt8>>(slice)   // set image to the cropped out slice
        }
    }

    func flipDiagonal() {
        if (image.width != image.height) {  // check if the image is a square, if not make it one
            squareImage()
        }
        
        for y in 0..<image.height { // loop through all y
            for x in 0..<y {    // loop until only the current y
                let pixelOriginal: RGBA<UInt8> = (image.pixelAt(x: x, y: y))!
                let pixelNew: RGBA<UInt8> = (image.pixelAt(x: y, y: x))!
                image[x, y] = pixelNew  // swap the values at (x, y) with (y, x)
                image[y, x] = pixelOriginal
            }
        }
    }
    
    func flipVertical() {
        image = image.yReversed()   // set image to be the y reversed image
    }
    
    func flipHorizontal() {
        image = image.xReversed()   // set image to be the x reversed image
    }
    
    func channelValue(channel: Int, value: Int) {
        for index in 0..<(image.width * image.height) { // loop through entire image
            let y = index % image.height    // calculate x and y coordinates
            let x = index / image.height
            
            switch (channel) {  // switch color channel
                case 0: image[x, y].red = UInt8(value); break   // set channel value to be value
                case 1: image[x, y].green = UInt8(value); break
                case 2: image[x, y].blue = UInt8(value); break
                default: break
            }
        }
    }
    
    func addValues(channel: Int, value: Int) {
        for index in 0..<(image.width * image.height) { // loop through entire image
            let y = index % image.height    // calculate x and y coordinates
            let x = index / image.height
            
            switch (channel) {  // switch channel
                case 0:
                    var redValue = Int(image[x, y].red) + value // new red value is equal to current red + amount to add
                    
                    if (redValue > 255) {   // if the value is greater than 255, set it to 255 so it is in a range of 0 to 255
                        redValue = 255
                    } else if (redValue < 0) {    // if the value is less than 0, set it to 0 so it is in a range of 0 to 255
                        redValue = 0
                    }
                    
                    image[x, y].red = UInt8(redValue)   // set image value to new value
                    break
                case 1:
                    var greenValue = Int(image[x, y].green) + value // new green value is equal to current green + amount to add
                    
                    if (greenValue > 255) {   // if the value is greater than 255, set it to 255 so it is in a range of 0 to 255
                        greenValue = 255
                    } else if (greenValue < 0) {    // if the value is less than 0, set it to 0 so it is in a range of 0 to 255
                        greenValue = 0
                    }
                    
                    image[x, y].green = UInt8(greenValue)   // set image value to new value
                    break
                case 2:
                    var blueValue = Int(image[x, y].blue) + value // new blue value is equal to current blue + amount to add
                    
                    if (blueValue > 255) {   // if the value is greater than 255, set it to 255 so it is in a range of 0 to 255
                        blueValue = 255
                    } else if (blueValue < 0) {    // if the value is less than 0, set it to 0 so it is in a range of 0 to 255
                        blueValue = 0
                    }
                    
                    image[x, y].blue = UInt8(blueValue)   // set image value to new value
                    break
                default: break
            }
        }
    }
    
    func addAll(red: Int, green: Int, blue: Int) {
        for index in 0..<(image.width * image.height) { // loop through entire image
            let y = index % image.height    // calculate x and y coordinates
            let x = index / image.height

            var redValue = Int(image[x, y].red) + red       // add addition values to current values
            var greenValue = Int(image[x, y].green) + green
            var blueValue = Int(image[x, y].blue) + blue
            
            if (redValue > 255) {       // check 0-255 range for red and adjust if necessary
                redValue = 255
            } else if (redValue < 0) {
                redValue = 0
            }
            
            if (greenValue > 255) {       // check 0-255 range for green and adjust if necessary
                greenValue = 255
            } else if (greenValue < 0) {
                greenValue = 0
            }
            
            if (blueValue > 255) {       // check 0-255 range for blue and adjust if necessary
                blueValue = 255
            } else if (blueValue < 0) {
                blueValue = 0
            }
            
            image[x, y].red = UInt8(redValue)   // update pixel values with new values
            image[x, y].green = UInt8(greenValue)
            image[x, y].blue = UInt8(blueValue)
        }
    }
    
    func swapChannel(channel1: Int, channel2: Int) {
        for index in 0..<(image.width * image.height) { // loop through entire image
            let y = index % image.height    // calculate x and y coordinates
            let x = index / image.height

            let pixel: RGBA<UInt8> = (image.pixelAt(x: x, y: y))!   // get current pixel
            
            if (channel1 == 0 && channel2 == 1) {   // swap the two values of each channel
                image[x, y].green = pixel.red       // red and green
                image[x, y].red = pixel.green
            } else if (channel1 == 0 && channel2 == 2) {
                image[x, y].blue = pixel.red        // red and blue
                image[x, y].red = pixel.blue
            } else if (channel1 == 1 && channel2 == 2) {
                image[x, y].blue = pixel.green      // green and blue
                image[x, y].green = pixel.blue
            }
        }
    }
    
    func keep(channel: Int) {
        for index in 0..<(image.width * image.height) { // loop through entire image
            let y = index % image.height    // calculate x and y coordinate
            let x = index / image.height
            
            switch (channel) {
                case 0: image[x, y].green = 0; image[x, y].blue = 0; break  // if red, zero green and blue
                case 1: image[x, y].red = 0; image[x, y].blue = 0; break    // if green, zero red and blue
                case 2: image[x, y].red = 0; image[x, y].green = 0; break   // if blue, zero red and green
                default: break
            }
        }
    }
    
    func mirrorVertical(top: Bool) {
        for x in 0..<(image.width) {    // loop through all x
            for y in 0..<(image.height / 2) {   // loop through half of y
                if (top) {  // if mirroring top
                    let pixel: RGBA<UInt8> = (image.pixelAt(x: x, y: y))!
                    image[x, image.height - y - 1] = pixel  // put value at x, y into pixel at (x, height - y - 1)
                } else {    // mirroring bottom
                    let pixel: RGBA<UInt8> = (image.pixelAt(x: x, y: image.height - y - 1))!
                    image[x, y] = pixel // put value at (x, height - y - 1) into pixel at (x, y)
                }
            }
        }
    }
    
    func mirrorHorizontal(left: Bool) {
        for x in 0..<(image.width / 2) {    // loop through half of x
            for y in 0..<(image.height) {   // loop through all of y
                if (left) { // if mirroring left into right
                    let pixel: RGBA<UInt8> = (image.pixelAt(x: x, y: y))!
                    image[image.width - x - 1, y] = pixel   // put value at (x, y) into pixel at (width - x - 1, y)
                } else {    // mirroring right into left
                    let pixel: RGBA<UInt8> = (image.pixelAt(x: image.width - x - 1, y: y))!
                    image[x, y] = pixel // put value at (width - x - 1, y) into pixel at (x, y)
                }
            }
        }
    }
    
    func mirrorDiagonal(leftRight: Bool) {
        if (image.width != image.height) {  // check if image is not a square
            squareImage()                   // square if necessary
        }
        
        for x in 0..<image.width {  // loop through all x
            for y in 0..<(image.height - x) {   // loop from y to height - x in each row
                if (leftRight) {    // if mirroring left
                    let pixel: RGBA<UInt8> = (image.pixelAt(x: y, y: x))!
                    image[image.width - x - 1, image.height - y - 1] = pixel    // put value at (x, y) into pixel at (width - x - 1, height - y - 1)
                } else {
                    let pixel: RGBA<UInt8> = (image.pixelAt(x: image.height - y - 1, y: image.width - x - 1))!
                    image[x, y] = pixel // put value at (width - x - 1, height - y - 1) into pixel at (x, y)
                }
            }
        }
    }
    
    func negate() {
        for index in 0..<(image.width * image.height) { // loop through entire image
            let y = index % image.height    // calculate x and y coordinate
            let x = index / image.height
            
            let red = 255 - image.pixelAt(x: x, y: y)!.red  // set each channel to 255 - current value
            let green = 255 - image.pixelAt(x: x, y: y)!.green
            let blue = 255 - image.pixelAt(x: x, y: y)!.blue
            let alpha = image.pixelAt(x: x, y: y)!.alpha

            image[x, y] = RGBA(red: red, green: green, blue: blue, alpha: alpha)    // load new values into color channels
        }
    }
    
    func convertToBinary() {
        for index in 0..<(image.width * image.height) { // loop through entire image
            let y = index % image.height    // calculate x and y coordinate
            let x = index / image.height

            let red = Double(image.pixelAt(x: x, y: y)!.red) * 0.21 // weighted average
            let green = Double(image.pixelAt(x: x, y: y)!.green) * 0.72
            let blue = Double(image.pixelAt(x: x, y: y)!.blue) * 0.07
            let alpha = image.pixelAt(x: x, y: y)!.alpha
            
            let gray = UInt8(red + green + blue)    // create gray pixel
            
            if (gray > 127) {   // if pixel is greater than 127
                image[x, y] = RGBA(red: 255, green: 255, blue: 255, alpha: alpha)   // make pixel white
            } else {    // if pixel is less than 127
                image[x, y] = RGBA(red: 0, green: 0, blue: 0, alpha: alpha) // make pixel black
            }
        }
    }
    
    func convertArray() -> [[Int]] {
        var imageArray: [[Int]] = Array(repeating: Array(repeating: 0, count: image.width), count: image.height)    // create array that is the same size as picture
        
        for y in 0..<imageArray.count {
            for x in 0..<imageArray[0].count {
                let red = Double(Int(image[x, y].red)) * 0.21       // convert to gray with weighted average
                let green = Double(Int(image[x, y].green)) * 0.72
                let blue = Double(Int(image[x, y].blue)) * 0.07
                imageArray[y][x] = Int(red + green + blue)  // set array value to gray
            }
        }
        
        return(imageArray)  // return created array
    }
    
    func convertArrayColor() -> [[[Int]]] {
        var imageArray: [[[Int]]] = Array(repeating: Array(repeating: Array(repeating: 0, count: 3), count: image.width), count: image.height)    // create array that is the same size as picture
         
        for y in 0..<imageArray.count {
            for x in 0..<imageArray[0].count {
                imageArray[y][x][0] = Int(getPixel(x: x, y: y).red) // load values for each color channel into appropriate array
                imageArray[y][x][1] = Int(getPixel(x: x, y: y).green)
                imageArray[y][x][2] = Int(getPixel(x: x, y: y).blue)
            }
        }
        
        return(imageArray)  // rotate created arraya
    }
    
    func manipulateImage(manipulation: Manipulation) {
        switch (manipulation) { // switch input
            case .flipVertical:     // run image manipulations through the features dialog
                self.flipVertical() // a lot of these are repetitive and do not need commenting in each scenario
                ViewController.log += "Flipped Vertically" // add feature to log
                break
            case .flipHorizontal:
                self.flipHorizontal()
                ViewController.log += "Flipped Horizontally"
                break
            case .flipDiagonal:
                self.flipDiagonal()
                ViewController.log += "Flipped Diagonally"
                break
            case .mirrorVerticalTop:
                self.mirrorVertical(top: true)
                ViewController.log += "Mirrorred Top Vertically"
                break
            case .mirrorVerticalBottom:
                self.mirrorVertical(top: false)
                ViewController.log += "Mirrorred Bottom Vertically"
                break
            case .mirrorHorizontalLeft:
                self.mirrorHorizontal(left: true)
                ViewController.log += "Mirrorred Left Horizontally"
                break
            case .mirrorHorizontalRight:
                self.mirrorHorizontal(left: false)
                ViewController.log += "Mirrorred Right Horizontally"
                break
            case .mirrorDiagonalTLBR:
                self.mirrorDiagonal(leftRight: true)
                ViewController.log += "Mirrorred TLBR Diagonally"
                break
            case .mirrorDiagonalBRTL:
                self.mirrorDiagonal(leftRight: false)
                ViewController.log += "Mirrorred BRTL Diagonally"
                break
            case .convertToGray:
                self.convertToGray()
                ViewController.log += "Converted To Gray"
                break
            case .convertToBinary:
                self.convertToBinary()
                ViewController.log += "Converted To Binary"
                break
            case .negate:
                self.negate()
                ViewController.log += "Negated"
                break
            case .rotate:
                self.rotate(degrees: Input.degrees) // pull extra values from the Input class if necessary
                ViewController.log += "Rotated \(Input.degrees) degrees"
                break
            case .resizeFactor:
                self.resize(factor: Input.resizeFactor)
                ViewController.log += "Resized by a factor of \(Input.resizeFactor)"
                break
            case .resizeExact:
                self.resizeExact(width: Input.resizeWidth, height: Input.resizeHeight)
                ViewController.log += "Resized to \(Input.resizeWidth)x\(Input.resizeHeight)"
                break
            case .squareImage:
                self.squareImage()
                ViewController.log += "Squared Image"
                break
            case .setRed:
                self.channelValue(channel: 0, value: Input.redChannel)  // hardcode some values so input validation is not needed, more buttons are easier here
                ViewController.log += "Set Red Channel to \(Input.redChannel)"
                break
            case .setGreen:
                self.channelValue(channel: 1, value: Input.greenChannel)
                ViewController.log += "Set Green Channel to \(Input.greenChannel)"
                break
            case .setBlue:
                self.channelValue(channel: 2, value: Input.blueChannel)
                ViewController.log += "Set Blue Channel to \(Input.blueChannel)"
                break
            case .swapRedGreen:
                self.swapChannel(channel1: 0, channel2: 1)
                ViewController.log += "Swapped Red and Green Channels"
                break
            case .swapRedBlue:
                self.swapChannel(channel1: 0, channel2: 2)
                ViewController.log += "Swapped Red and Blue Channels"
                break
            case .swapGreenBlue:
                self.swapChannel(channel1: 1, channel2: 2)
                ViewController.log += "Swapped Green and Blue Channels"
                break
            case .keepRed:
                self.keep(channel: 0)
                ViewController.log += "Kept Red Channel"
                break
            case .keepGreen:
                self.keep(channel: 1)
                ViewController.log += "Kept Green Channel"
                break
            case .keepBlue:
                self.keep(channel: 2)
                ViewController.log += "Kept Blue Channel"
                break
            case .addRed:
                self.addValues(channel: 0, value: Input.addRedChannel)
                ViewController.log += "Added \(Input.addRedChannel) to Red Channel"
                break
            case .addGreen:
                self.addValues(channel: 1, value: Input.addGreenChannel)
                ViewController.log += "Added \(Input.addGreenChannel) to Green Channel"
                break
            case .addBlue:
                self.addValues(channel: 2, value: Input.addBlueChannel)
                ViewController.log += "Added \(Input.addBlueChannel) to Blue Channel"
                break
            case .addRGB:
                self.addAll(red: Input.addRedChannel, green: Input.addGreenChannel, blue: Input.addBlueChannel)
                ViewController.log += "Added \(Input.addRedChannel) to Red, \(Input.addGreenChannel) to Green, and \(Input.addBlueChannel) to Blue Channels"
                break
            case .gradMag:
                var array = convertArray()  // run first half of edge detection process
                let borderReflect: [[Int]] = EdgeDetection.createBorder(kernel: Input.k, image: &array)
                let kernel = EdgeDetection.createKernel(kernel: Input.k, sigma: Input.sigma)
                let filter = EdgeDetection.filter(kernel: kernel, image: borderReflect)
                let gradX = EdgeDetection.calcGradientX(image: filter), gradY = EdgeDetection.calcGradientY(image: filter)
                let gradMag = EdgeDetection.calcGradMag(gradX: gradX, gradY: gradY)
                setArray(array: ArrayUtility.normalize(array: ArrayUtility.toIntArray(array: gradMag)))
                ViewController.log += "Calculated Gradient Magnitude"
                break
            case .edgeDetection:
                var array = convertArray()  // run edge detection process, there is more detail in the Edge Detection powerpoint on how this works
                let borderReflect: [[Int]] = EdgeDetection.createBorder(kernel: Input.k, image: &array)
                let kernel = EdgeDetection.createKernel(kernel: Input.k, sigma: Input.sigma)
                let filter = EdgeDetection.filter(kernel: kernel, image: borderReflect)
                let gradX = EdgeDetection.calcGradientX(image: filter), gradY = EdgeDetection.calcGradientY(image: filter)
                let gradMag = EdgeDetection.calcGradMag(gradX: gradX, gradY: gradY)
                var gradAngle = EdgeDetection.calcGradAngle(gradX: gradX, gradY: gradY)
                let gradAngleAdj = EdgeDetection.adjustGradAngle(gradAngle: &gradAngle)
                let calcNonMaxSupp = EdgeDetection.calcNonMaxSupp(gradMag: gradMag, gradAngleAdj: gradAngleAdj)
                let doubleThresh = EdgeDetection.doubleThresh(nonMaxSupp: ArrayUtility.toDoubleArray(array: ArrayUtility.normalize(array: ArrayUtility.toIntArray(array: calcNonMaxSupp))), min: Input.min, max: Input.min * 3)
                let calcEdge = EdgeDetection.calcEdge(doubleThresh: doubleThresh)
                ViewController.log += "Detected Image"
                setArray(array: calcEdge)
                break
            case .sketch:
                var array = convertArray()  // run all but last step for edge detection
                let borderReflect: [[Int]] = EdgeDetection.createBorder(kernel: Input.k, image: &array)
                let kernel = EdgeDetection.createKernel(kernel: Input.k, sigma: Input.sigma)
                let filter = EdgeDetection.filter(kernel: kernel, image: borderReflect)
                let gradX = EdgeDetection.calcGradientX(image: filter), gradY = EdgeDetection.calcGradientY(image: filter)
                let gradMag = EdgeDetection.calcGradMag(gradX: gradX, gradY: gradY)
                var gradAngle = EdgeDetection.calcGradAngle(gradX: gradX, gradY: gradY)
                let gradAngleAdj = EdgeDetection.adjustGradAngle(gradAngle: &gradAngle)
                let calcNonMaxSupp = EdgeDetection.calcNonMaxSupp(gradMag: gradMag, gradAngleAdj: gradAngleAdj)
                let doubleThresh = EdgeDetection.doubleThresh(nonMaxSupp: ArrayUtility.toDoubleArray(array: ArrayUtility.normalize(array: ArrayUtility.toIntArray(array: calcNonMaxSupp))), min: Input.min, max: Input.min * 3)
                let sketch = Sketch.sketch(dThresh: doubleThresh, gradAng: gradAngle, lineScale: Input.lineScale)   // pass doubleThresh and gradAngle into sketch method, pull linescale from file
                setArray(array: ArrayUtility.negate(array: ArrayUtility.normalize(array: sketch)))  // negate and normalize result
                ViewController.log += "Ran Basic Sketch"
                break
            case .sketch2:
                var array = convertArray()
                let borderReflect: [[Int]] = EdgeDetection.createBorder(kernel: Input.k, image: &array)
                let kernel = EdgeDetection.createKernel(kernel: Input.k, sigma: Input.sigma)
                let filter = EdgeDetection.filter(kernel: kernel, image: borderReflect) // run edge detection up through filter
                let sketch = Sketch.sketch2(filtered: filter, lineScale: Input.lineScale, dThreshMin: Double(Input.min), dThreshMax: Double(Input.min * 3)) // run all-in-one sketch method using filter and user input
                let blendedSketch = Sketch.addSketch(gray: filter, sketch: ArrayUtility.normalize(array: sketch))   // blend sketch with the gray filter image for a gray tone result
                setArray(array: ArrayUtility.normalize(array: blendedSketch))   // set image array to normalized blended sketch
                ViewController.log += "Created Grayscale Sketch"
                break
            case .sketchColor:
                var array = convertArray()
                let borderReflect: [[Int]] = EdgeDetection.createBorder(kernel: Input.k, image: &array)
                let kernel = EdgeDetection.createKernel(kernel: Input.k, sigma: Input.sigma)
                let filter = EdgeDetection.filter(kernel: kernel, image: borderReflect) // run edge detection up through filter
                let sketch = Sketch.sketch2(filtered: filter, lineScale: Input.lineScale, dThreshMin: Double(Input.min), dThreshMax: Double(Input.min * 3)) // run all-in-one sketch method using filter and user input
                let blendedSketchColor = Sketch.addSketch(image: Sketch.brightnessChange(rgb: convertArrayColor(), multiplier: 1.35), sketch: ArrayUtility.normalize(array: sketch)) // blend sketch with color image for a color result
                setArray(array: ArrayUtility.normalize(array: blendedSketchColor))  // set image to normalized blended color sketch
                ViewController.log += "Created Color Sketch"
                break
        }
    }
}

public enum Manipulation: Int {
    case flipHorizontal = 0 // assign each test feature a number for readability
    case flipVertical = 1
    case flipDiagonal = 2
    case mirrorVerticalTop = 3
    case mirrorVerticalBottom = 4
    case mirrorHorizontalLeft = 5
    case mirrorHorizontalRight = 6
    case mirrorDiagonalTLBR = 7
    case mirrorDiagonalBRTL = 8
    case convertToGray = 9
    case convertToBinary = 10
    case negate = 11
    case resizeFactor = 12
    case resizeExact = 13
    case rotate = 14
    case squareImage = 15
    case setRed = 16
    case setGreen = 17
    case setBlue = 18
    case swapRedGreen = 19
    case swapRedBlue = 20
    case swapGreenBlue = 21
    case keepRed = 22
    case keepGreen = 23
    case keepBlue = 24
    case addRed = 25
    case addGreen = 26
    case addBlue = 27
    case addRGB = 28
    case gradMag = 29
    case edgeDetection = 30
    case sketch = 31
    case sketch2 = 32
    case sketchColor = 33
}
