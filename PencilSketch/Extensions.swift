//
//  Extensions.swift
//  PencilSketch
//
//  Created by Eric Johns on 8/29/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//
// These extensions were pulled of StackOverflow, see references for the source

import UIKit

extension UIImage {
    func fixedOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if (imageOrientation == UIImage.Orientation.up) {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (imageOrientation == UIImage.Orientation.down
            || imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        }
        
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        }
        
        if (imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2));
        }
        
        if (imageOrientation == UIImage.Orientation.upMirrored
            || imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: cgImage!.colorSpace!,
                                      bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored
            ) {
            
            
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
            
        } else {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizeCamera() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1536.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 1536 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1536.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
}

extension String {
    func checkInt() -> Bool {
        return(Int(self) != nil)
    }
}

extension UITextField {
    func addNumericAccessory(addPlusMinus: Bool) {
        let numberToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default

        var accessories : [UIBarButtonItem] = []

        if addPlusMinus {
            accessories.append(UIBarButtonItem(title: "+/-", style: UIBarButtonItem.Style.plain, target: self, action: #selector(plusMinusPressed)))
            accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding after
        }

        accessories.append(UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadClear)))
        accessories.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))   //add padding space
        accessories.append(UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(numberPadDone)))

        numberToolbar.items = accessories
        numberToolbar.sizeToFit()

        inputAccessoryView = numberToolbar
    }

    @objc func numberPadDone() {
        self.resignFirstResponder()
    }

    @objc func numberPadClear() {
        self.text = ""
    }

    @objc func plusMinusPressed() {
        guard let currentText = self.text else {
            return
        }
        if currentText.hasPrefix("-") {
            let offsetIndex = currentText.index(currentText.startIndex, offsetBy: 1)
            let substring = currentText[offsetIndex...]  //remove first character
            self.text = String(substring)
        }
        else {
            self.text = "-" + currentText
        }
    }
}
