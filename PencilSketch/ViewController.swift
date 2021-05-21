//
//  ViewController.swift
//  PencilSketch
//
//  Created by Eric Johns on 8/28/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//

import UIKit
import SwiftImage

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!    // pull controls from interface
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static var pictureID: Int = 0               // numerical ID of picture if default
    static let picture: Picture = Picture()     // instantiate picture class for manipulation
    
    static var log: String = ""                 // stored list of controls
    
    static var pictureGallery = false           // switch boolean for if taking pictures of camera or from gallery
    
    static var originalImage: UIImage = UIImage(named: "townhall")! // image that will be reset to
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.scrollView.minimumZoomScale = 1.0      // set zoom scales for pinching in and out
        self.scrollView.maximumZoomScale = 20.0
        
        imageView.image = ViewController.picture.getUIImage()   // grab UI image from picture class
        ViewController.originalImage = ViewController.picture.getUIImage()  // set original image to current image, no manipulations have been preformed yet
        
        Input.k = UserDefaults.standard.integer(forKey: "k")        // load last sketch settings from file
        Input.sigma = UserDefaults.standard.double(forKey: "sigma")
        Input.min = UserDefaults.standard.integer(forKey: "thresh")
        Input.lineScale = UserDefaults.standard.double(forKey: "lineScale")
    
        NotificationCenter.default.addObserver(self, selector: #selector(changePicture), name: NSNotification.Name(rawValue: "changePicture"), object: nil) // add changePicture event for when the picture is changed in the PictureController
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(resetImage))
        imageView.addGestureRecognizer(longPress)   // add gesture for resetting image
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(showLog))
        imageView.addGestureRecognizer(imageTap)    // add gesture for viewing log
    }
    
    @objc func changePicture() {
        if (ViewController.pictureID == 0){
            takePicture()   // take picture
            ViewController.pictureGallery = true    // picture is from camera
        } else if (ViewController.pictureID == 1) {
            choosePicture() // choose picture from gallery
            ViewController.pictureGallery = false   // picture is from gallery
        } else {    // picture is pre programmed
            ViewController.picture.setPicture(name: PictureController.pictures[ViewController.pictureID])
            imageView.image = ViewController.picture.getUIImage()   // load picture from resources and set imageView to that picture
            ViewController.originalImage = ViewController.picture.getUIImage()  // update original image
        }
        
        clearLog()  // clear the transformation log, a new image has been replaced
    }
    
    @objc func resetImage() {
        ViewController.picture.setPicture(image: ViewController.originalImage)  // set picture to original
        imageView.image = ViewController.originalImage  // update imageView
        clearLog()  // clear log, all past manipulations are gone
    }
    
    @objc func showLog() {
        self.present(Prompt.prompt(title: "Transformation Log", message: "\(ViewController.log)"), animated: true, completion: nil) // display log
    }
    
    @IBAction func saveImage(_ sender: Any) {
        let saveDialog = UIAlertController(title: "Save image", message: "Select the format you would like to save to.", preferredStyle: .alert)    // create save dialog
        
        let png = UIAlertAction(title: "Save as PNG", style: .default, handler: { (action) in   // add save as png option
            let data = ViewController.picture.getUIImage().pngData()!   // pull png data from image
            let pngImage = UIImage(data: data)
            UIImageWriteToSavedPhotosAlbum(pngImage!, nil, nil, nil)    // write to gallery
            self.view.makeToast("Successfully saved as PNG")            // display success message
        })
        
        let jpg = UIAlertAction(title: "Save as JPG", style: .default, handler: { (action) in   // add save as jpg option
            let data = ViewController.picture.getUIImage().jpegData(compressionQuality: 1.0)!   // pull jpg data from image
            let jpegImage = UIImage(data: data)
            UIImageWriteToSavedPhotosAlbum(jpegImage!, nil, nil, nil)   // write to gallery
            self.view.makeToast("Successfully saved as JPG")    // display success message
        })
        
        saveDialog.addAction(png)   //  add buttons to dialog
        saveDialog.addAction(jpg)
        saveDialog.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(saveDialog, animated: true, completion: nil)   // display created dialog
    }
    
    @IBAction func pencilSketch(_ sender: Any) {
        self.present(Prompt(controller: self).promptPencilSketch(), animated: true, completion: nil) // show the pencil sketch
    }
    
    @IBAction func testClick(_ sender: Any) {
        self.present(Prompt(controller: self).promptFeatures(), animated: true, completion: nil)    // display prompt features dialog
    }
    
    func manipulateImage(manipulation: Manipulation) {
        let startTime = DispatchTime.now().uptimeNanoseconds    // get current system time
        
        DispatchQueue.global(qos: .background).async {  // switch to background thread
            ViewController.picture.manipulateImage(manipulation: manipulation)  // manipulate image
            
            DispatchQueue.main.async {  // switch back to main thread
                self.imageView.image = ViewController.picture.getUIImage()  // update image view with manipulated image
                let timeTaken = DispatchTime.now().uptimeNanoseconds - startTime    // calculate time taken to run manipulation
                ViewController.log += " (\(timeTaken / 1000000)ms) \n"  // add time taken to log
            }
        }
    }
    
    func choosePicture() {
        let imagePicker = UIImagePickerController() // create image picker dialog
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum  // set source to gallery
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)  // present dialog
    }
    
    func takePicture() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            // check if device has a camera
            let imagePicker = UIImagePickerController() // create camera dialog
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera  // set source to camera
            imagePicker.cameraDevice = .rear    // set to default rear camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)  // present dialog
        }
    }
    
    func clearLog() {
        ViewController.log = "" // clear log texta
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil) // hide dialog
        let image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage).fixedOrientation()    //pull image from camera/gallery and fix orientation if needed
        ViewController.picture.setPicture(image: ViewController.pictureGallery ? image.resizeCamera()! : image) // load picture into Picture class
        imageView.image = ViewController.picture.getUIImage()   // update imageView
        ViewController.originalImage = ViewController.picture.getUIImage()  // set picture to original image
        navigationController?.popToRootViewController(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView   // return imageView as scrollable
    }
}
