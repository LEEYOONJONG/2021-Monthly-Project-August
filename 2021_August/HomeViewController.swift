//
//  HomeViewController.swift
//  2021_August
//
//  Created by YOONJONG on 2021/08/25.
//

import UIKit
import KeychainSwift
class HomeViewController: UIViewController {
    
    @IBOutlet weak var todayCommitView: UIView!
    @IBOutlet weak var continuousCommitView: UIView!
    
    @IBOutlet weak var todayCommitButton: UIButton!
    @IBOutlet weak var commitNumLabel: UILabel!
    @IBOutlet weak var continuousCommitNumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
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
    
    // dark mode 여부 바뀌면 색상 즉시 변경
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateUI()
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
        UIView.animate(withDuration: 0.3, animations: {
            self.todayCommitButton.transform = CGAffineTransform(rotationAngle:(180.0 * .pi)/180);
        })
        UIView.animate(withDuration: 0.3, animations: {
            self.todayCommitButton.transform = CGAffineTransform(rotationAngle:(360.0 * .pi)/180);
        })
        
        OperationQueue().addOperation {
            LoginManager.shared.getUser()
            
        }
    }
    
    @IBAction func tempClicked(_ sender: Any) {
        OperationQueue().addOperation {
            print("Clicked!!!")
            
        }
    }
    
    func updateUI(){
        // 버전별, 다크모드 여부에 따라 색상 따로 설정
        let todayCommitViewColor = UIColor {(trait) -> UIColor in
            if #available(iOS 13, *){
                if trait.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.9493537545, green: 0.9761642814, blue: 0.9253637195, alpha: 1)
                }
            } else {
                return #colorLiteral(red: 0.9493537545, green: 0.9761642814, blue: 0.9253637195, alpha: 1)
            }
        }
        let continuousCommitViewColor = UIColor {(trait) -> UIColor in
            if #available(iOS 13, *){
                if trait.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.07951391488, green: 0.1685524583, blue: 0.3377684057, alpha: 1)
                } else {
                    return #colorLiteral(red: 0.890386641, green: 0.9659765363, blue: 0.9694517255, alpha: 1)
                }
            } else {
                return #colorLiteral(red: 0.890386641, green: 0.9659765363, blue: 0.9694517255, alpha: 1)
            }
        }
        todayCommitView.layer.cornerRadius = 10
        continuousCommitView.layer.cornerRadius = 10
        todayCommitView.layer.backgroundColor = todayCommitViewColor.cgColor
        continuousCommitView.layer.backgroundColor = continuousCommitViewColor.cgColor
    }
    
}
