//
//  LoginViewController.swift
//  UserSystem
//
//  Created by Антон Тимонин on 21.05.2020.
//  Copyright © 2020 Антон Тимонин. All rights reserved.
//

import UIKit
import FirebaseAuth

func styleTextField(_ textfield: UITextField) {
    
    textfield.tintColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
    
}

func styleFilledButton(_ button: UIButton) {
    
    // Filled rounded corner style
    button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
    
    button.layer.cornerRadius = 25.0
    button.tintColor = UIColor.white
}

final class LoginViewController: UIViewController {
    
    private let segueIdentifier = "loginSegue"
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleTextField(emailText)
        styleTextField(passwordText)
        styleFilledButton(loginButton)
        styleFilledButton(registerButton)

        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        warnLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener { [weak self](auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        }
    }
    
    func displayWarningLabel(withText: String) {
        warnLabel.text = withText
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
            self?.warnLabel.alpha = 1
        }) { [weak self] complete in
            self?.warnLabel.alpha = 0
        }
    }
    
    @objc func keyBoardDidHide(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyBoardFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + keyBoardFrameSize.height)
        
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardFrameSize.height, right: 0)
    }
    
    @objc func keyBoardDidShow(notification: Notification) {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard
            let email = emailText.text,
            let password = passwordText.text,
            email != "",
            password != ""
        else {
            displayWarningLabel(withText: "Информация о пользователе некорректна")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
        }
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard
            let email = emailText.text,
            let password = passwordText.text,
            email != "",
            password != ""
        else {
            displayWarningLabel(withText: "Информация о пользователе некорректна")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            if error == nil {
                if user != nil {
                    //self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
                } else {
                    print("User is not created")
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
