//
//  PictureController.swift
//  PencilSketch
//
//  Created by Eric Johns on 9/4/19.
//  Copyright © 2019 Eric Johns. All rights reserved.
//

import UIKit

class PictureCell: UITableViewCell {
    @IBOutlet weak var pictureName: UILabel!    // declare a label and imageview to hold in each tableview cell
    @IBOutlet weak var picture: UIImageView!
}

class PictureController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    static let pictureNames = ["Take Picture", "Select Picture", "Town Hall", "Bus", "Tree", "Bouquet", "Space", "Gorge", "Island", "Kayak", "Eric", "Flower", "Mark", "Nature 1", "Nature 2", "Nature 3", "Nature 4", "Nature 5", "City" ]  // list to hold cell texts
    static let pictures = ["camera", "gallery", "townhall", "bus", "tree", "bouquet", "space", "gorge", "island", "kayak", "eric", "flower", "mark", "nature1", "nature2", "nature3", "nature4", "nature5", "city"] // list to hold picture resource names
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.selectRow(at: IndexPath(row: ViewController.pictureID, section: 0), animated: true, scrollPosition: .middle)  // automatically select row for current picture
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(PictureController.pictures.count)    // return number of pre-loaded pictures
        // will be the amount of rows to add to the tableview
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PictureCell    // make cell reusable, makes scrolling smoother and less resource intensive
        cell.pictureName.text = PictureController.pictureNames[indexPath.row]   // pull image name from list using the id
        cell.picture.image = UIImage(named: "\(PictureController.pictures[indexPath.row])_icon")    // pull image from list using the ID from file
        
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ViewController.pictureID = indexPath.row    // copy picture ID to main class
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePicture"), object: nil)  // change the picture of the imageView on the main screen
        
        if (indexPath.row != 0 && indexPath.row != 1) {
            navigationController?.popToRootViewController(animated: true)   // return to main view controller
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(150) // set default height to 150
    }
}
