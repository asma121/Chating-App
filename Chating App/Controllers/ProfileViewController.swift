//
//  ProfileViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageIV: UIImageView!
    
//    var firstName:String?
//    var lastName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        profileImageIV.layer.masksToBounds = true
        profileImageIV.layer.cornerRadius = profileImageIV.layer.frame.height / 2
       

        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logOutAlert))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPorfilePicture()
        
       // print("\(firstName) \(lastName)")
        
    }
    
    @objc func logOutAlert(){
        let alert = UIAlertController(title: "Log Out", message: "would you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { action in
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let LoginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                let nav = UINavigationController(rootViewController: LoginVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
            catch {
                print("Faild to logout")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadPorfilePicture() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        
        let fileName = "\(safeEmail)_profile_picture.png"
        let path = "images/\(fileName)"
        
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                self.getImage(imageView: self.profileImageIV, url: url)
            case .failure(let error):
                print("faield to get dawonload url : \(error)")
            }
        }
    }
    
    func getImage(imageView : UIImageView , url : URL){
        URLSession.shared.dataTask(with: url, completionHandler: { data ,_ , error in
            
            guard let data = data , error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.profileImageIV.image = image
            }
        }).resume()
    }

}
