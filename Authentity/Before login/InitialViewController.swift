//
//  InitialViewController.swift
//  Authentity
//
//  Created by LiudasBar on 2020-05-05.
//  Copyright © 2020 LiudasBar. All rights reserved.
//

import UIKit
import LocalAuthentication

class InitialViewController: UIViewController, cameraPermissions {
    
    //Continue button related
    @IBOutlet weak var continueButton: UIButton!
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if continueButton.titleLabel!.text == "Try again" {
            biometrics()
        } else if continueButton.titleLabel!.text == "Continue" {
            performSegue(withIdentifier: "loginSegue", sender: nil)
            infoLabel.text = ""
            UIView.animate(withDuration: 0.5) {
                self.continueButton.alpha = 0
            }
        } else if continueButton.titleLabel!.text == "Quit Authentity" {
            exit(0)
        }
    }
    
    //Remove data and continue button related
    @IBOutlet weak var removeDataButton: UIButton!
    @IBAction func removeDataButtonAction(_ sender: UIButton) {
        let authArray: [String] = []
        
        UserDefaults.standard.set(authArray, forKey: "authArray")
        UserDefaults.standard.set(false, forKey: "faceID")
        
        let alert = UIAlertController(title: "Warning!", message: "Before you enable Biometrics authentication, lock and unlock your device or check Biometrics permissions in Settings!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
              switch action.style{
              case .default:
                self.continueButton.alpha = 0
                self.removeDataButton.alpha = 0
                self.infoLabel.alpha = 0
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
              default:
                print("error")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var infoLabel: UILabel!
    
    let myContext = LAContext()
    let myLocalizedReasonString = "Unlock Authentity"
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    
    //Executed when Continue button is pressed on Splash Screen View Controller
    func cameraPermissionsRequest() {
        //Must be run in main thread
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.infoLabel.text = "Camera access not granted. You may want to enable it in Settings later."
            self.infoLabel.alpha = 1
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //For making the connection with SplashScreenViewController so it could pass data back
        if segue.destination is SplashScreenViewController {
            let vc = segue.destination as? SplashScreenViewController
            vc?.delegate = self
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        continueButton.setTitle("Continue", for: .normal)
        continueButton.alpha = 0
        removeDataButton.alpha = 0
        infoLabel.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.biometrics()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.layer.cornerRadius = 10
        continueButton.layer.masksToBounds = true
        
        removeDataButton.layer.cornerRadius = 10
        removeDataButton.layer.masksToBounds = true
        
        continueButton.setTitle("Continue", for: .normal)
        
        continueButton.alpha = 0
        removeDataButton.alpha = 0
        infoLabel.alpha = 0
        
        infoLabel.text = ""
    }
}

extension InitialViewController {
    
    func biometrics() {
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if launchedBefore  {
            //If biometry check is enabled
            if UserDefaults.standard.bool(forKey: "faceID") {
                
                let context = LAContext()
                var error: NSError?
                
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    let reason = "Unlock Authentity"
                    
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                        [weak self] success, authenticationError in
                        
                        DispatchQueue.main.async {
                            if success {
                                //Authenticated successfully
                                UIView.animate(withDuration: 0.5) {
                                    self!.continueButton.alpha = 0
                                    self!.removeDataButton.alpha = 0
                                    self!.infoLabel.alpha = 0
                                }
                                //Must be run in main thread
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self!.continueButton.setTitle("Continue", for: .normal)
                                    self!.performSegue(withIdentifier: "loginSegue", sender: nil)
                                }
                            } else {
                                //Did not authenticate successfully
                                self!.continueButton.setTitle("Try again", for: .normal)
                                //self!.infoLabel.text = "Authentication failed"
                                UIView.animate(withDuration: 0.5) {
                                    self!.continueButton.alpha = 1
                                    self!.infoLabel.alpha = 1
                                }
                            }
                        }
                    }
                    self.myContext.localizedFallbackTitle = ""  //Disable password log in
                    
                } else {
                    //No biometry available, exceeded biometry authentication checks or Touch ID / Face ID permissions not enabled
                    infoLabel.text = "No biometry available. To continue using Authentity, quit Authentity, lock and unlock your phone or check Biometrics permissions in Settings!"
                    
                    UIView.animate(withDuration: 1) {
                        self.removeDataButton.alpha = 1
                        self.continueButton.alpha = 1
                        self.continueButton.setTitle("Quit Authentity", for: .normal)
                        self.infoLabel.alpha = 1
                    }
                }
            } else {
                //If biometry check is not enabled
                performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        } else {
            //First time launch Splash Screen
            performSegue(withIdentifier: "splashScreenSegue", sender: nil)
            continueButton.setTitle("Continue", for: .normal)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UIView.animate(withDuration: 0.5) {
                self.continueButton.alpha = 1
            }
        }
    }
    
}
