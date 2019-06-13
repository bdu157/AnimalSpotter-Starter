//
//  LoginViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var signInButton: UIButton!
    
    var apiController: APIController?
    var loginType = LoginType.signUp

    override func viewDidLoad() {
        super.viewDidLoad()

        // customize button appearance
        guard isViewLoaded else {return}
        self.signInButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
        self.signInButton.tintColor = .white
        self.signInButton.layer.cornerRadius = 8.0
    }
    
    // MARK: - Action Handlers
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // perform login or sign up operation based on loginType
        guard let apiController = self.apiController else {return}
            if let username = self.usernameTextField.text,
                !username.isEmpty,
                let password = self.passwordTextField.text,
                !password.isEmpty {
                let user = User(username: username, password: password)
                
                if loginType == .signUp {
                    apiController.signUp(with: user, completion: { (error) in
                        if let error = error {
                            NSLog("Error occurred during sign up: \(error)")
                            return
                        }
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Sign up", message: "Successful", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true, completion: {
                                self.loginType = .signIn
                                self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                                self.signInButton.setTitle("Sign In", for: .normal)
                            })
                        }
                    })
                } else {
                    self.apiController?.signIn(with: user, completion: { (error) in
                        if let error = error {
                            NSLog("Error occurred during sign up: \(error)")
                        } else {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    
    @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
        // switch UI between modes
        if sender.selectedSegmentIndex == 0 {
            self.loginType = .signUp
            self.signInButton.setTitle("Sign Up", for: .normal)
        } else {
            self.loginType = .signIn
            self.signInButton.setTitle("Sign In", for: .normal)
        }
    }
}
