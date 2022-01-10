//
//  RegisterViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var userFirstNameTF: UITextField!
    @IBOutlet weak var userLastNameTF: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userAddressTF: UITextField!
    @IBOutlet weak var userImageIV: UIImageView!
    
    let spinner = JGProgressHUD(style: .dark)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Register"
        userPassword.isSecureTextEntry = true
        
        userImageIV.layer.masksToBounds = true
        userImageIV.layer.cornerRadius = userImageIV.frame.height / 2
        //userImageIV.layer.cornerRadius = userImageIV.frame.width / 2
        
        
        
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
        
        spinner.show(in: view)
        
        DatabaseManger.shared.userExists(with: email) { exsist in
            guard  !exsist else{
                // alert user exsist ..
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult , error  in
                
                guard let strongSelf = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                guard let result = authResult, error == nil else {
                    print("Error creating user )")
                    return
                }
                let user = result.user
                print("Created User: \(user)")
                
                let ChatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                DatabaseManger.shared.insertUser(with: ChatUser, completion: { success in
                    if success {
                        // upload image..
                        guard let image = strongSelf.userImageIV.image , let data = image.pngData() else {
                            return 
                        }
                        
                        let fileName = ChatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result  in
                            switch result {
                            case .success(let dawonloadURL):
                                UserDefaults.standard.set(dawonloadURL, forKey: "profile_picture_url")
                                print(dawonloadURL)
                            case .failure(let error):
                                print("storage manager erorr : \(error)")
                            }
                        }
                    }
                })
                
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
