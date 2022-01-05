//
//  RegisterViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var userFirstNameTF: UITextField!
    @IBOutlet weak var userLastNameTF: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userAddressTF: UITextField!
    @IBOutlet weak var userImageIV: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Register"
        userPassword.isSecureTextEntry = true
    }
    
    @IBAction func imageViewTapped(_ sender: Any) {
        self.showPhotoAlert()
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        guard let firstName = userFirstNameTF.text , !firstName.isEmpty,
              let lastName = userLastNameTF.text , !lastName.isEmpty,
              let email = userAddressTF.text , !email.isEmpty,
              let password = userPassword.text , !password.isEmpty else{
             // show an  alert .. 
               return
        }
        
        DatabaseManger.shared.userExists(with: email) { exsist in
            guard  !exsist else{
                // alert user exsist ..
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult , error  in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard let result = authResult, error == nil else {
                    print("Error creating user )")
                    return
                }
                let user = result.user
                print("Created User: \(user)")
                
                DatabaseManger.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
  
    }
    
 
}

extension RegisterViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func showPhotoAlert(){
        let alert = UIAlertController(title: "Take Photo From", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.getPhoto(type: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.getPhoto(type: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func getPhoto(type: UIImagePickerController.SourceType ){
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            print("image not found")
            return
        }
        
        userImageIV.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
