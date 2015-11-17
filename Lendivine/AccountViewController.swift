//
//  AccountViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/17/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This view controller displays the user's account information such as name, email, lender Id, and balance.

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var lenderIDLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var kivaAPI: KivaAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the kivaAPI handle
        self.kivaAPI = KivaAPI.sharedInstance
        
        populateAccountData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Make KivaAPI calls to retrieve and render the user's kiva account information.
    func populateAccountData() {
        // account name and lender ID
        kivaAPI!.kivaOAuthGetUserAccount() {success, error, account in
            if success {
                if let firstName = account?.firstName {
                    if let lastName = account?.lastName {
                        self.nameLabel.text = firstName + " " + lastName
                    }
                }
                if let lenderID = account?.lenderID {
                    self.lenderIDLabel.text = lenderID
                }
            } else {
                print("error retrieving user account: \(error?.localizedDescription)")
            }
        }
        
        // email
        kivaAPI!.kivaOAuthGetUserEmail(){ success, error, email in
            if success {
                if let email = email {
                    self.emailLabel.text = email
                }
            } else {
                print("error retrieving user email: \(error?.localizedDescription)")
            }
        }
        
        // balance
        kivaAPI!.kivaOAuthGetUserBalance(){ success, error, balance in
            if success {
                if let balance = balance {
                    self.balanceLabel.text = balance
                }
            } else {
                print("error retrieving user balance: \(error?.localizedDescription)")
            }
        }
    }

}
