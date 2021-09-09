import UIKit
import UserNotifications
import RealmSwift

class TimeSettingViewController: UIViewController {
    let interval = 0.1
    var count = 0
    var pickerTime = "알릴 시각을 선택해주세요."
    
    @IBOutlet weak var lblPickerTime: UILabel!
    @IBOutlet weak var backgroundAlertSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, Error in
            print("알림여부 : ", didAllow)
        })
        lblPickerTime.text = pickerTime
        readTimeDB()
    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "HH시 mm분"
        pickerTime =  "매일 "+formatter.string(from: datePickerView.date) + "에 알려드려요."
        lblPickerTime.text = pickerTime
        
        
        let realm = try! Realm()
        let savedTime = realm.objects(TimeDB.self)
        if savedTime.count == 0 { // 처음이면
            print("처음이다 => \(formatter.string(from: datePickerView.date))로 생성함")
            let timeDB = TimeDB()
            timeDB.storedTime = formatter.string(from: datePickerView.date)
            try! realm.write{
                realm.add(timeDB)
            }
        } else { // 이미 저장된 시각 있다면 수정한다.
            print("처음 아니다 => \(formatter.string(from: datePickerView.date))로 수정됨")
            let taskToUpdate = savedTime[0]
            try! realm.write {
                taskToUpdate.storedTime = formatter.string(from: datePickerView.date)
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Ssukssuk"
        content.subtitle = "오늘 GitHub에 커밋하셨나요?"
        content.body = "커밋할 시각이에요!"
        content.sound = UNNotificationSound.default
        
        let hour = datePickerView.calendar.component(.hour, from: datePickerView.date)
        let minute = datePickerView.calendar.component(.minute, from: datePickerView.date)
        print("hour : \(hour), minute : \(minute)")
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "SsukssukAlert", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch){
        if sender.isOn{
            print("커밋 알림 키")
            LoginManager.shared.backgroundFetchEnabled = true
        } else {
            print("커밋 알림 끔")
            LoginManager.shared.backgroundFetchEnabled = false
        }
    }
    func readTimeDB(){
        let realm = try! Realm()
        let savedTime = realm.objects(TimeDB.self)
        if savedTime.count != 0 { // 이미 저장된 시각 있다면 불러온다
            print("savedTime이 있으므로 \(String(describing: savedTime[0].storedTime!))를 불러온다")
            lblPickerTime.text =  "매일  \(String(describing: savedTime[0].storedTime!))에 알려드려요."
        }
    }
}

class TimeDB: Object {
    @Persisted(primaryKey: true) var _id:ObjectId
    @Persisted var storedTime:String?
    
    convenience init(storedTime: String){
        self.init()
        self.storedTime = storedTime
    }
}

//func createTime(){
//    let realm = try! Realm()
//    let timeDB = TimeDB()
//    timeDB.storedTime =
//}


