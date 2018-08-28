/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2018B
 Assessment: Assignment
 Author: Duong Huu Khang
 ID: s3635116
 Created date: 15/08/2018
 Acknowledgement:
 https://stackoverflow.com/questions/35561977/how-do-i-make-a-keyboard-push-the-view-up-when-it-comes-on-screen-xcode-swift
 http://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/
 */

import UIKit
import CoreData

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var urlText: UITextField!
    
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    let imagePicker = UIImagePickerController()
    
    func configureView() {
        // Update the user interface for the detail item.
        if let song = editItem {
            if let img = imageView {
                img.image = UIImage(data: song.image!)
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                img.addGestureRecognizer(gestureRecognizer)
            }
            if let textField = titleText {
                textField.text = song.title!
            }
            if let textField = artistText {
                textField.text = song.artist!
            }
            if let textField = yearText {
                textField.text = String(song.year)
            }
            if let textField = urlText {
                textField.text = song.url
            }
        }
    }
    
    // choose an image from photo library when the user tap the image
    @objc func imageTapped(sender: UIGestureRecognizer) {
        print("change image here")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        configureView()
        titleText.delegate = self
        artistText.delegate = self
        yearText.delegate = self
        urlText.delegate = self
    }
    
    // hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleText.resignFirstResponder()
        artistText.resignFirstResponder()
        yearText.resignFirstResponder()
        urlText.resignFirstResponder()
        return false
    }
    
    // move the view accordingly when the keyboard appears and disappears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification: notification) - 80.0
            view.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            view.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var editItem: Song? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // pick an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // save the edited object when done is tapped
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        // don't perform segue if one of the three required fields is not filled
        if titleText.text!.isEmpty || artistText.text!.isEmpty || yearText.text!.isEmpty {
            alertLabel.text = "Missing required field(s)"
        } else {
            alertLabel.text = ""
            performSegue(withIdentifier: "editDone", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDone" {
            editItem?.image = UIImagePNGRepresentation(imageView.image!)
            editItem?.title = titleText.text!
            editItem?.artist = artistText.text!
            let yearStr = yearText.text!
            if(Int16(yearStr) == nil){
                editItem?.year = -1
            } else {
                editItem?.year = Int16(yearStr)!
            }
            editItem?.url = urlText.text
            PersistenceService.saveContext()
        }
    }
    
}
