//
//  Input.swift
//  PencilSketch
//
//  Created by Eric Johns on 9/20/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//

import Foundation
import SwiftImage

class Input {
    // this class holds values temporarily that are inputted in the Prompt class
    // they are referenced when the manipulations requiring data are ran
    static var k: Int = 2                   // edge detection, grad mag, pencil sketch
    static var sigma: Double = 1.35         // edge detection, grad mag, pencil sketch
    static var min: Int = 8                 // edge detection, pencil sketch
    static var lineScale: Double = 0.015    // pencil sketch
    
    static var resizeFactor: Double = 0.5   // resizeFactor
    static var degrees: Int = 90            // rotate
        
    static var redChannel: Int = 0          // channel value red
    static var greenChannel: Int = 0        // channel value green
    static var blueChannel: Int = 0         // channel value blue
    
    static var addRedChannel: Int = 0       // add value red
    static var addGreenChannel: Int = 0     // add value green
    static var addBlueChannel: Int = 0      // add value blue
    
    static var resizeHeight: Int = 500      // resizeExact
    static var resizeWidth: Int = 500       // resizeExact
}
