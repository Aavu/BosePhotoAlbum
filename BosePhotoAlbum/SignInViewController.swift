//
//  SignInViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signIn_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signIn_btn.layer.masksToBounds = true
        signIn_btn.layer.cornerRadius = signIn_btn.frame.height/2
        
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        emailTextField.leftViewMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func signIn(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                print("not valid")
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
                return
            }
            
            let layout = UICollectionViewFlowLayout()
            
            let homeVC = HomeViewController(collectionViewLayout: layout)
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    

}
