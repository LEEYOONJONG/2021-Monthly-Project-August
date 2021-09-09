import UIKit
import UserNotifications

class TimeSettingViewController: UIViewController {
    let interval = 0.1
    var count = 0
    var pickerTime = "알릴 시각을 선택해주세요."
    
    @IBOutlet weak var lblPickerTime: UILabel!
    @IBOutlet weak var backgroundAlertSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, Error in
            print(didAllow)
        })
        lblPickerTime.text = pickerTime
    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "HH시 mm분"
        pickerTime =  "매일 "+formatter.string(from: datePickerView.date) + "에 알려드려요."
        lblPickerTime.text = pickerTime
        
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
    

}
