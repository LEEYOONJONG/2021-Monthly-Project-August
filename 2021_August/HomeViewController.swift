//
//  HomeViewController.swift
//  2021_August
//
//  Created by YOONJONG on 2021/08/25.
//

import UIKit
import KeychainSwift
import Charts

class HomeViewController: UIViewController {
    
    @IBOutlet weak var todayCommitView: UIView!
    @IBOutlet weak var continuousCommitView: UIView!
    @IBOutlet weak var commitGraphView: UIView!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var todayCommitButton: UIButton!
    @IBOutlet weak var commitNumLabel: UILabel!
    @IBOutlet weak var continuousCommitNumLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        chartInit()
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
        LoginManager.shared.commitlogCallback = {dateArr, commitArr in
            OperationQueue.main.addOperation {
                self.chartSet(dateArr, commitArr)
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
        let commitGraphViewColor = UIColor {(trait) -> UIColor in
            if #available(iOS 13, *){
                if trait.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.235019207, green: 0.1052800193, blue: 0, alpha: 1)
                } else {
                    return #colorLiteral(red: 1, green: 0.9595724097, blue: 0.9074905539, alpha: 1)
                }
            } else {
                return #colorLiteral(red: 1, green: 0.9595724097, blue: 0.9074905539, alpha: 1)
            }
        }
        todayCommitView.layer.cornerRadius = 10
        continuousCommitView.layer.cornerRadius = 10
        commitGraphView.layer.cornerRadius = 10
        
        todayCommitView.layer.backgroundColor = todayCommitViewColor.cgColor
        continuousCommitView.layer.backgroundColor = continuousCommitViewColor.cgColor
        commitGraphView.layer.backgroundColor = commitGraphViewColor.cgColor
    }
    func chartInit(){
        lineChartView.noDataText = "계산 중입니다."
        lineChartView.noDataFont = .systemFont(ofSize: 20)
        lineChartView.noDataTextColor = .lightGray
    }
    func chartSet(_ dateArr:[String], _ commitArr:[String]){
        
        // 데이터 생성
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dateArr.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(commitArr[i])!)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "커밋 수")
        // 차트 모양 -
        chartDataSet.mode = .cubicBezier
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = 2
        // 차트 컬러
        chartDataSet.colors = [.systemGreen]
        chartDataSet.fill = Fill(color: .systemGreen)
        chartDataSet.fillAlpha = 0.7
        chartDataSet.drawFilledEnabled = true
        // 선택, 줌 안되게
        chartDataSet.highlightEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        // ** 축
        // x축 레이블 위치, 포맷 조정
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateArr)
        // x축 레이블 개수 최대, y축 오른쪽 숨기기
        lineChartView.xAxis.setLabelCount(4, force: false)
        lineChartView.rightAxis.enabled = false
        // 기타
        lineChartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        // bottom space to zero
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        
        // 데이터 삽입
        let chartData = LineChartData(dataSet: chartDataSet)
        chartData.setDrawValues(false)
        lineChartView.data = chartData
        // animation
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
    }
}

