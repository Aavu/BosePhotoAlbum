//
//  SignInViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signIn_btn: UIButton!
    
    @IBOutlet var notificationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        notificationLabel.isHidden = true
        signIn_btn.layer.masksToBounds = true
        signIn_btn.layer.cornerRadius = signIn_btn.frame.height/2
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(progressView)
        progressView.center = view.center
        progressView.hidesWhenStopped = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            self.notificationLabel.isHidden = true
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    let progressView = UIActivityIndicatorView(style: .gray)
    
    @IBAction func signIn(_ sender: Any) {
        progressView.startAnimating()
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                print("not valid")
                return
        }
//        let email = "test@gmail.com"
//        let password = "aaaaaa"
//        let email = "violinsimma@gmail.com"
//        let password = "Sankar63"
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
                if error._code == 17009 {
                    self.notificationLabel.isHidden = false
                    self.progressView.stopAnimating()
                }
                return
            }
            self.progressView.stopAnimating()
            let layout = UICollectionViewFlowLayout()
            let homeVC = HomeViewController(collectionViewLayout: layout)
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    

}
