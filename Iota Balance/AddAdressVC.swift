//
//  AddAdressVC.swift
//  Iota Balance
//
//  Created by onehitwonder on 12.06.19.
//  Copyright © 2019 onehitwonder. All rights reserved.
//

import UIKit

protocol addAdressButtonTapped {
    
    func addAdressButtonTapped()
    
}

class AddAdressVC: UIViewController, UITextViewDelegate {
    
    let model = IotaModel()
    var delegate:addAdressButtonTapped?
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var adressTextView: UITextView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var popUp: UIView!
    @IBOutlet weak var addAdressButton: UIButton!
    @IBOutlet weak var errorMessageConstraint: NSLayoutConstraint!
    @IBOutlet weak var slideInMessageView: UIView!
    @IBOutlet weak var slideInMessageText: UILabel!
    
    @IBOutlet weak var stackViewTitle: UILabel!
    @IBOutlet weak var stackViewTextView: UIStackView!
    
    
    var myTapGestureRecognizer = UITapGestureRecognizer()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup for noticing Taps in dimView
        dimView!.addGestureRecognizer(myTapGestureRecognizer)
        myTapGestureRecognizer.addTarget(self, action: #selector(tapDimViewDismiss(_:)))
        dimView!.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.

        
        // Hides the Keyboard when tapped somewhere or Return key is hit
        adressTextView.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        // adressTextView Style
        adressTextView.layer.cornerRadius = 5
        adressTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        adressTextView.layer.borderWidth = 0.5
        adressTextView.clipsToBounds = true
        
        // stackView spacing
        stackView.setCustomSpacing(30, after: stackViewTitle)
        stackView.setCustomSpacing(50, after: stackViewTextView)
        
        
        // Button Style
        addAdressButton.layer.cornerRadius = 15
        //addAdressButton.layer.backgroundColor = UIColor.blue.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Rounded corners
        popUp.layer.cornerRadius = 15
        
        // dimView 0 for later animation
        dimView.alpha = 0
        slideInMessageView.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Animate the DimView in
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.dimView.alpha = 0.5
            
        }, completion: nil)
        
    }
    
    // Detects touch in dimView
    
    @objc func tapDimViewDismiss(_ sender: Any) {
        
        // Clear labels and return to Main
        adressTextView.text.removeAll()
        returnToMainView()
        
    }
    
    // MARK: - Maybe implement later
   /* func textFieldShouldReturn(_ adressTextView: UITextView) -> Bool {
        
        // When Return key is hit, keyboard gets dissmissed and new adress is appended
        adressTextView.resignFirstResponder()
        appendNewAdress()
        
        return true
        
    } */
    
    @IBAction func addAdressTapped(_ sender: Any) {
        
        // When Button is tapped, new adress gets appended
        appendNewAdress()
        adressTextView.text.removeAll()
        
    }
    
    
    func appendNewAdress() {
        
        let charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz9"
        let charset = CharacterSet(charactersIn: charactesAllowed)
        let newAdress = adressTextView.text?.uppercased()
        
       guard newAdress!.rangeOfCharacter(from: charset) != nil else {
            
            slideInMessage(Text: "Adress can only contain Characters from A-Z and 9!", Color: UIColor.red)
            return
            
        }
        
        if newAdress!.count == 81 {
            
            IotaModel.adress.append(newAdress!)
            IotaModel.defaults!.removeObject(forKey: "SavedArray")
            IotaModel.defaults!.set(IotaModel.adress, forKey: "SavedArray")
            
            // Dismisses Popup and returns to Main View
            self.slideInMessageView.alpha = 0
            returnToMainView()
            self.delegate?.addAdressButtonTapped()
            
        }
        else if newAdress!.count > 81 {
            
            // Trim Adress to 81 Chars
            let trimmedAdress = String(newAdress![...80])
            IotaModel.adress.append(trimmedAdress)
            IotaModel.defaults!.removeObject(forKey: "SavedArray")
            IotaModel.defaults!.set(IotaModel.adress, forKey: "SavedArray")
            self.slideInMessageView.alpha = 0
            returnToMainView()
            self.delegate?.addAdressButtonTapped()
            
        }
        else {
            
            slideInMessage(Text: "Adress must contain 81 Characters!", Color: UIColor.red)
            
        }
        
    }
    
    func slideInMessage(Text:String ,Color:UIColor ) {
        
        slideInMessageView.alpha = 1
        slideInMessageText.text = Text
        slideInMessageView.backgroundColor = Color
        
        // Show PopUP Adress has to be 81 Characters long
        self.slideInMessageView.alpha = 1
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut , animations: {
            
            self.errorMessageConstraint.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 4, options: .curveEaseOut, animations: {
            
            self.slideInMessageView.alpha = 0
            self.errorMessageConstraint.constant = -130
            self.view.layoutIfNeeded()
            
            })
        
    }
    
    func returnToMainView() {
        
        //Animate the DimView out , TODO: animate the rest out
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            
            self.dimView.alpha = 0
            
        }, completion: { (sucess) in
            self.dismiss(animated: true, completion: {
                
                // TODO: Clear the labels
                
            })
        })
    }
}


