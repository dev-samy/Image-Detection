//
//  ViewController.swift
//  Image Detection
//
//  Created by Abdelrahman Samy on 31.10.2019.
//  Copyright © 2019 Abdelrahman Samy. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImagePicker=UIImagePickerController()
        ImagePicker.delegate = self
        ImagePicker.sourceType = .camera
    }
    
    var ImagePicker:UIImagePickerController!
    
    @IBOutlet weak var Nav: UINavigationBar!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var ImageDes: UITextView!
    
    @IBAction func BuTakePic(_ sender: Any) {
        present(ImagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ImageView.image=info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        ImagePicker.dismiss(animated: true, completion: nil)
        PictureIdentify(image: (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!)
    }
    
    func PictureIdentify(image:UIImage){
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Cannot load model")
        }
        let requset = VNCoreMLRequest(model: model){
            [weak self] requset, error in
            
            guard let results = requset.results as? [VNClassificationObservation],
                let firstResult = results.first else {
                    fatalError("Cannot get result from ML")
            }
            
            DispatchQueue.main.async {
                self?.ImageDes.text = "confidence = \( Int(firstResult.confidence * 100))%  \n identifire :  \((firstResult.identifier))"
                
                let utTerance = AVSpeechUtterance(string: (self?.ImageDes.text)!)
                utTerance.voice = AVSpeechSynthesisVoice(language: "en-gb")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utTerance)
            }
        }
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Cannot convert to CiImage")
        }
        let imageHandler = VNImageRequestHandler(ciImage:ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do{
                try imageHandler.perform([requset])
            }catch{
                print("Error \(error)")
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    
}

