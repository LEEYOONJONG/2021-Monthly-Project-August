//
//  HomeViewController.swift
//  2021_August
//
//  Created by YOONJONG on 2021/08/25.
//

import UIKit
import KeychainSwift
class HomeViewController: UIViewController {
    
    @IBOutlet weak var commitNumLabel: UILabel!
    @IBOutlet weak var continuousCommitNumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OperationQueue().addOperation {
            if KeychainSwift().get("accessToken") == nil {
                LoginManager.shared.requestCode()
            } else {
                LoginManager.shared.getUser()
            }
        }
        
        LoginManager.shared.callback = { str1, str2 in
            OperationQueue.main.addOperation {
                self.commitNumLabel.text = str1
                self.continuousCommitNumLabel.text = str2+"일"
            }
        }
    }
    
    @IBAction func githubSignupClicked(_ sender: Any) {
        if KeychainSwift().get("accessToken") == nil {
            LoginManager.shared.requestCode()
        } else {
            print("이미 등록되어 있습니다.")
        }
    }
    @IBAction func todayCommitClicked(_ sender: Any) {
        OperationQueue().addOperation {
            LoginManager.shared.getUser()
            
        }
    }
    
    @IBAction func tempClicked(_ sender: Any) {
        OperationQueue().addOperation {
            print("Clicked!!!")
            
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
