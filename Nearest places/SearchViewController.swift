//
//  SearchViewController.swift
//  Nearest bar
//
//  Created by Матвей on 04.04.2022.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var userSearch: String?
    
    var searchActive: Bool {
        if textField.text == "" {
            return false
        }
        return true
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.textField.delegate = self

        searchButton.layer.cornerRadius = 15
        if searchActive == false {
            searchButton.isEnabled = false
        }
    }
    
   
    
    @IBAction func backgroundTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    
    //MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if text.isEmpty {
         searchButton.isEnabled = false
        } else {
         searchButton.isEnabled = true
            }
         return true
    }
    
    //MARK: Segue
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CompassSegue" {
            
            userSearch = textField.text?.lowercased()
            let compassViewController = segue.destination as! CompassViewController
            compassViewController.search = self.userSearch
            
        }
    }
    

    
}
