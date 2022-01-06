//
//  LoginViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
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
    
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                return
            }
            UserDefaults.standard.set(email, forKey: "email")
            let user = result.user.uid
            print("logged in user: \(user)")
            // if this succeeds, dismiss
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
        
    }
        
}


