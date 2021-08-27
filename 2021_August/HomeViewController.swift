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
                if str2 == "0일" {
                    self.continuousCommitNumLabel.text = "오늘 커밋을 안했어요!"
                } else {
                    self.continuousCommitNumLabel.text = str2
                }
            }
        }
    }
    
    @IBAction func githubSignupClicked(_ sender: Any) {
        if KeychainSwift().get("accessToken") == nil {
            LoginManager.shared.requestCode()
        } else {
            let alert = UIAlertController(title: "알려드려요", message: "이미 GitHub 계정이 등록되어 있어요.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now()+2
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
            print("이미 등록되어 있습니다.")
        }
    }
    @IBAction func resignupClicked(_ sender: Any) {
        let alert = UIAlertController(title: "주의", message: "먼저 Safari에서 GitHub 계정을 로그아웃 해주세요.", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "돌아가기", style: .default, handler: nil)
        let okAction = UIAlertAction(title: "재등록", style: .cancel){action in
            LoginManager.shared.requestCode()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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
