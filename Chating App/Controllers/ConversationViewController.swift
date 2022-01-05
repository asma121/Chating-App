//
//  ConversationViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
  
        validateAuth()
    }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let LoginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            let nav = UINavigationController(rootViewController: LoginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)

        }
    }
}

