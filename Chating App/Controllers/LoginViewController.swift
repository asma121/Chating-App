//
//  LoginViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let spinner = JGProgressHUD(style: .dark)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        passwordField.isSecureTextEntry = true
    }

    @IBAction func logInButtonPressed(_ sender: Any) {
        
        guard let email = emailField.text , !email.isEmpty else {
            return
        }
        
        guard let password = passwordField.text , !password.isEmpty else {
            return
        }
        
        spinner.show(in: view)
     
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                return
            }
            
            let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
            DatabaseManger.shared.getDataFor(path: safeEmail, completion: {  result in
                switch result {
                case.success(let data):
                    guard let userData = data as? [String:Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
//                    let profileVC = self?.storyboard?.instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
//                    profileVC.firstName = firstName
//                    profileVC.lastName = lastName
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case.failure(let error):
                    print("faild to read data : \(error)")
                }
            })
            
            
            UserDefaults.standard.set(email, forKey: "email")
            let user = result.user.uid
            print("logged in user: \(user)")
            // if this succeeds, dismiss
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
        
    }
        
}


