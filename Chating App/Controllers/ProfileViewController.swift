//
//  ProfileViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logOutAlert))
    }
    
    @objc func logOutAlert(){
        let alert = UIAlertController(title: "Log Out", message: "would you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { action in
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let LoginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                let nav = UINavigationController(rootViewController: LoginVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false)
            }
            catch {
                print("Faild to logout")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        present(alert, animated: true, completion: nil)
    }

}
