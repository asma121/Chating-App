//
//  RegisterViewController.swift
//  Chating App
//
//  Created by administrator on 03/01/2022.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var userFirstNameTF: UITextField!
    @IBOutlet weak var userLastNameTF: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userAddressTF: UITextField!
    @IBOutlet weak var userImageIV: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
    }
}
