import UIKit
import Alamofire
import SwiftSoup
import UserNotifications
import Foundation
import KeychainSwift

class LoginManager {
    static let shared = LoginManager()
    
    let client_id = "ac6468124c1c1e12dd21"
    let client_secret = "a0c30c5dfaa7224a0928c3635250d3ad26bf709f"
    var githubURL = ""
    var commitNum = ""
    
    var callback:((String, String) -> ())?
    var commitlogCallback:(([String], [String]) -> ())?
    
    func requestCode(){
        let scope="user"
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(client_id)&scope=\(scope)"
        OperationQueue.main.addOperation {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                // redirect to scene(_:openURLContexts:) if user authorized
            }
        }
    }
    func requestAccessToken(with code:String){
        let url = "https://github.com/login/oauth/access_token"
        let parameters = ["client_id": client_id, "client_secret":client_secret, "code":code]
        let headers:HTTPHeaders = ["Accept": "application/json"]
        OperationQueue().addOperation {
            AF.request(url, method: .post, parameters:parameters, headers:headers)
                .responseJSON{(response) in
                    switch response.result{
                    case let .success(json):
                        if let dic = json as? [String:String]{
                            let accessToken = dic["access_token"] ?? ""
                            KeychainSwift().set(accessToken, forKey: "accessToken")
                            print(dic["access_token"])
                            print(dic["scope"])
                            print(dic["token_type"])
                            self.getUser()
                            //                        self.getRepo() // json 바깥을 감싸는 소괄호 제거 성공못함.
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
        }
    }
    func getUser(){
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()+1, execute: {
            self.callback?("계산 중입니다...", "이것도 계산 중입니다...")
        })
        let url = "https://api.github.com/user"
        let accessToken = KeychainSwift().get("accessToken") ?? ""
        let headers:HTTPHeaders = ["Accept" : "application/vnd.github.v3+json", "Authorization":"token \(accessToken)"]
        AF.request(url, method: .get, parameters:[:], headers: headers)
            .responseJSON(completionHandler: {(response) in
                switch response.result{
                case .success(let jsonData):
                    //                    print(json as! [String: Any])
//                    print(jsonData)
                    let jsonDictionary = [jsonData]
                    for i in jsonDictionary{
                        if let obj = i as? [String: Any]{
                            if let result = obj["html_url"]{
                                let url = String(describing: result) // Any to String
                                print("방문할 URL : ", url)
                                self.githubURL = url
                                self.fetch()
                            }
                        }
                    }
                    
                case .failure:
                    print("getUser failure")
                }
            })
    }
    func fetch() {
        AF.request(self.githubURL).responseString { response in
            guard let responseValue = response.value else{
                return
            }
            OperationQueue().addOperation {
                do {
                    let doc:Document = try SwiftSoup.parse(responseValue)
                    var continuousCommit:Int = 0
                    // 전체 탐색
                    
                    // HomeVC에 넘겨주기 위한 배열
                    var dateArray:[String]=[]
                    var countArray:[String]=[]
                    
                    for week in 1...53{
                        // 퍼센트 뷰에 표시
                        for day in 1...7{
                            let element:Elements = try doc.select("#js-pjax-container > div.container-xl.px-3.px-md-4.px-lg-5 > div > div.flex-shrink-0.col-12.col-md-9.mb-4.mb-md-0 > div:nth-child(2) > div > div.mt-4.position-relative > div.js-yearly-contributions > div > div > div > svg > g > g:nth-child(\(week)) > rect:nth-child(\(day))")
                            for i in element{
                                print(try i.attr("data-date"), try i.attr("data-count"))
                                
                                // callback으로 념겨주기 위한
                                dateArray.append(try i.attr("data-date"))
                                countArray.append(try i.attr("data-count"))
                                
                                if Int(try i.attr("data-count"))! > 0 {
                                    continuousCommit += 1
                                } else {
                                    continuousCommit = 0
                                }
                                let nowDate = Date()
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                dateFormatter.timeZone = TimeZone(abbreviation: "KST")
                                let stringDate = dateFormatter.string(from: nowDate)
                                if (try i.attr("data-date") == stringDate){
                                    print("오늘의 commit 수는 ", try i.attr("data-count"))
                                    self.commitNum = "\(Int(try i.attr("data-count")) ?? -1)"
                                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()+1, execute: {
                                        self.callback?("\(self.commitNum)회", "\(continuousCommit)일")
                                    })
                                    // 여기서 새로운 뷰 컨트롤러로 데이터를 segue 등으로 넘겨야 할듯
                                }
                            }
                        }
                        
                    }
                    //필요할까? -> 필요 없음
//                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()+1, execute: {
                        self.commitlogCallback?(dateArray, countArray)
//                    })
                }
                
                catch{
                    print("error occured")
                }
            }
        }
    }
}
