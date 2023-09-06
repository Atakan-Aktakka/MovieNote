//
//  DetailsVC.swift
//  MovieNote
//
//  Created by Atakan Aktakka on 4.09.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var mainText: UITextField!
    
    @IBOutlet weak var categoryText: UITextField!
    
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    

    var chosenMovie = ""
    var chosenMovieId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenMovie != "" {
            
            //saveButton.isEnabled = false
            saveButton.isHidden = true
            //core data
            let stringUUID = chosenMovieId!.uuidString
            print(stringUUID)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
            let idString = chosenMovieId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            mainText.text = name
                        }
                        
                        if let category = result.value(forKey: "category") as? String{
                            categoryText.text = category
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
                
            }catch{
                
            }
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            mainText.text = ""
            categoryText.text = ""
            yearText.text = ""
        }
        
        //Recognizer
        let gestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newMovie = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: context)
        
        newMovie.setValue(mainText.text!, forKey: "name")
        newMovie.setValue(categoryText.text!, forKey: "category")
        
        if let year = Int(yearText.text!){
            newMovie.setValue(year, forKey: "year")
        }
        
        newMovie.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newMovie.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("başarılı")
        }catch{
            print("Hata var")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
