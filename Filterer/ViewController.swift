//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var filteredImage: UIImage?
    var originalImage: UIImage?
    
    @IBOutlet weak var originalLabelView: UIView!
    
    var filterWasApplied: Bool = false
    var showsOriginal: Bool = true
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var secondaryImageView: UIImageView!
        
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var secondaryMenuStack: UIStackView!
    @IBOutlet var filterSlider: UISlider!
    @IBOutlet var filterCollection: UICollectionView!
    @IBOutlet var screenCompareButton: UIButton!
    
    let availableFilters = ["Saturation", "Grey", "Sharpen", "Washout", "Blur", "Edges", "Embossing"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.white.withAlphaComponent(0.65)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryImageView.alpha = 0.0
        originalLabelView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        filterCollection.dataSource = self
        filterCollection.delegate = self
        filterCollection.backgroundColor = UIColor.white.withAlphaComponent(0.65)
    }

    // MARK: Share
    
    @IBAction func onShare(_ sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    
    @IBAction func onNewPhoto(_ sender: AnyObject) {
        hideEditSlider()
        hideFilterCollection()
        editButton.isEnabled = false
        editButton.isSelected = false
        screenCompareButton.isEnabled = false
        compareButton.isEnabled = false
        compareButton.isSelected = false
        if showsOriginal {
            compareImages(compareButton)
        }
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Filter Menu
    
    @IBAction func onFilter(_ sender: UIButton) {
        if (sender.isSelected) {
            hideFilterCollection()
            sender.isSelected = false
            
        } else {
            showFilterCollection()
            sender.isSelected = true
            screenCompareButton.isEnabled = false
        }
    }
    
//----------------------------------------------Edit slider for Saturation Filter----------------------------------------------
    
    @IBAction func onEdit(_ sender: UIButton) {
        if (sender.isSelected) {
            hideEditSlider()
            sender.isSelected = false
        }//if
        else {
            if filterCollection.isHidden == false {
                hideFilterCollection()
            }//if
            showEditSlider()
            sender.isSelected = true
        }//else
    }
    
    func showEditSlider() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryMenu.alpha = 1.0
        }) 
    }
    
    func hideEditSlider() {
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryMenu.alpha = 0
            }, completion: { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }) 
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        imageView.image = secondaryImageView.image!
        let imageProcessor = ImageProcessor(image: RGBAImage(image: imageView.image!)!)
        if let newImage = imageProcessor.saturation(Int(sender.value)) {
            imageView.image = newImage
            filteredImage = newImage
            filterWasApplied = true
        }
    }
    
//----------------------------------------------Filter methods----------------------------------------------
    
    @IBAction func applyFilter(_ sender: UIButton) {
        secondaryImageView.image = imageView.image
        let imageProcessor = ImageProcessor(image: RGBAImage(image: imageView.image!)!)
        if let newImage = imageProcessor.findAndApplyFilter(sender.titleLabel!.text!) {
            secondaryImageView.alpha = 1
            imageView.alpha = 0
            imageView.image = newImage
            self.imageView.alpha = 1
            UIView.animate(withDuration: 0.4, animations: {
                self.secondaryImageView.alpha = 0
            }) 
            filteredImage = newImage
            filterWasApplied = true
            showsOriginal = false
            compareButton.isEnabled = true
            if sender.titleLabel!.text! == "Saturation" {
                editButton.isEnabled = true
            }//if
            else {
                editButton.isEnabled = false
            }//else
            hideFilterCollection()
        }
    }
    
    @IBAction func compareImages(_ sender: UIButton) {
        if filterWasApplied {
            if !showsOriginal {
                showsOriginal = true
                originalLabelView.isHidden = false
                UIView.animate(withDuration: 0.4, animations: {
                    self.secondaryImageView.alpha = 1
                }) 
                if sender.titleLabel!.text == "Compare" {
                    sender.isSelected = true
                }//if sender is 'compare button'
                
            }//if filtered image is present
            else {
                if compareButton.isSelected == true && sender.titleLabel!.text != "Compare" {
                    return
                }//if
                UIView.animate(withDuration: 0.4, animations: {
                    self.secondaryImageView.alpha = 0
                }) 
                showsOriginal = false
                originalLabelView.isHidden = true
                if sender.titleLabel!.text == "Compare" {
                    sender.isSelected = false
                }//if sender is 'compare button'
            }//else if original image is present
        }//if filterWasApplied
    }
    
//----------------------------------------------Collection View methods----------------------------------------------
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return availableFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filterCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilterCellCollection
        let filterName = availableFilters[indexPath.section]
        cell.filterName.text = filterName
        cell.filterButton.setTitle(filterName, for: UIControlState())
        cell.filterSample.image = filteredImageForCollectionViewCell(filterName)
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.65)
        return cell
    }
    
    func filteredImageForCollectionViewCell(_ name: String) -> UIImage? {
        let scaledImage = resizedImage(imageView.image!, toSize: CGSize(width: 75, height: 75))
        let imageProcessor = ImageProcessor(image: RGBAImage(image: scaledImage)!)
        if let newImage = imageProcessor.findAndApplyFilter(name) {
            return newImage
        }//if
        else {
            return nil
        }//else
    }
    
    
    func showFilterCollection() {
        if editButton.isSelected {
            hideEditSlider()
            editButton.isSelected = false
        }
        filterCollection.reloadData()
        filterCollection.isHidden = false
        filterCollection.alpha = 0
        screenCompareButton.isEnabled = false
        UIView.animate(withDuration: 0.4, animations: {
            self.filterCollection.alpha = 1.0
        }) 
    }
    
    func hideFilterCollection() {
        screenCompareButton.isEnabled = true
        UIView.animate(withDuration: 0.4, animations: {
            self.filterCollection.alpha = 0
            }, completion: { completed in
                if completed == true {
                    self.filterCollection.isHidden = true
                    self.filterButton.isSelected = false
                }
        }) 
    }
    
    func resizedImage(_ image:UIImage, toSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    

}

