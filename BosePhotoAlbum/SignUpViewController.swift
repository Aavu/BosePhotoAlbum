//
//  SignUpViewController.swift
//  BosePhotoAlbum
//
//  Created by Raghavasimhan Sankaranarayanan on 3/17/19.
//  Copyright © 2019 Aavu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var signUp_btn: UIButton!
    @IBOutlet var signIn_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUp_btn.layer.masksToBounds = true
        signUp_btn.layer.cornerRadius = signUp_btn.frame.height/2
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        
        firstNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: firstNameTextField.frame.height))
        firstNameTextField.leftViewMode = .always
        
        lastNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: lastNameTextField.frame.height))
        lastNameTextField.leftViewMode = .always
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        notificationLabel.isHidden = true
        signIn_btn.isHidden = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            notificationLabel.isHidden = true
            signIn_btn.isHidden = true
        case passwordTextField:
            firstNameTextField.becomeFirstResponder()
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func signUp(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text
            else {
                print("not valid")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                if let error = error {
                    switch AuthErrorCode(rawValue: error._code) {
                    case .emailAlreadyInUse?:
                        print("Email already in use")
                        self.notificationLabel.isHidden = false
                        self.signIn_btn.isHidden = false
                    default:
                        print("Other error")
                    }
                }
                return
            }
            print("successfully authenticated")
            
            let dbRef = Database.database().reference(fromURL: "https://bose-photo-album.firebaseio.com/")
            guard let uid = authResult?.user.uid else { return }
            let userRef = dbRef.child("users").child(uid)
            let values = ["firstName": firstName, "lastName": lastName, "email":email]
            userRef.updateChildValues(values, withCompletionBlock: { (err, dbRef) in
                if err != nil {
                    print(err!)
                    return
                }
                print("successfully created user")
                let layout = UICollectionViewFlowLayout()
                let homeVC = HomeViewController(collectionViewLayout: layout)
                self.navigationController?.pushViewController(homeVC, animated: true)
            })
        }
    }
    
}
