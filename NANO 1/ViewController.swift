//
//  ViewController.swift
//  NANO 1
//
//  Created by Reza Mac on 26/04/22.
//

import UIKit
import CoreData
import SimpleCore

struct CashFlow {
    let id: String
    let item: String
    let amount: Int
    let type: String
    let date: Date
}

class ViewController: UIViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!

    @IBOutlet weak var spendingTotalLabel: UILabel!
    @IBOutlet weak var incomeTotalLabel: UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var bgViewColor: UIView!
    
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceAmount: UILabel!
    var balanceObj: [NSManagedObject] = []
    var balanceArr: [Int] = []
    var cashFlowArr: [CashFlow] = []
    var cashFlowObj: [NSManagedObject] = []
    var balanceAddedBool: Bool?
    
    var incomeTotal = 0
    var spendingTotal = 0
    
    
    let numberFormatter = NumberFormatter()
    let simpleCoreBalance = SimpleCore(entity: "Balance", coreData: "NANO_1")
    let simpleCoreCashflow = SimpleCore(entity: "Cashflow", coreData: "NANO_1")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.locale = Locale(identifier: "id_ID")
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
//        simpleCoreCashflow.delete(option: "all", attr: "", value: "") //RESET ALL DATA CASHFLOW
//        simpleCoreBalance.delete(option: "all", attr: "", value: "") //RESET ALL DATA BALANCE

        balanceFetch()
        cashFlowFetch()
        if cashFlowArr.count == 0 {
            noDataLabel.text = "No data, all added records will be shown here"
        }
        else {
            noDataLabel.text = ""

        }
        
        for i in 0 ..< cashFlowArr.count {
            if cashFlowArr[i].type == "income"{
                incomeTotal = incomeTotal + cashFlowArr[i].amount
            }
            else if cashFlowArr[i].type == "spending" {
                spendingTotal = spendingTotal + cashFlowArr[i].amount
            }
        }
        incomeTotalLabel.text = numberFormatter.string(from: NSNumber(value: incomeTotal))
        spendingTotalLabel.text = numberFormatter.string(from: NSNumber(value: spendingTotal))

        firstView.layer.cornerRadius = 10
        firstView.layer.shadowOpacity = 0.3
        firstView.layer.shadowRadius = 2
        firstView.layer.shadowOffset = CGSize(width: 1, height: 1)

        secondView.layer.cornerRadius = 10
        secondView.layer.shadowOpacity = 0.3
        secondView.layer.shadowRadius = 2
        secondView.layer.shadowOffset = CGSize.zero
        secondView.layer.masksToBounds = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nib, forCellReuseIdentifier: "customCell")
        
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.blue.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x : 0.0, y : -1)
        gradient.endPoint = CGPoint(x :0.0, y: 0.5) // you need to play with 0.15 to adjust gradient vertically
        gradient.frame = view.bounds
        bgViewColor.layer.addSublayer(gradient)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

    }
    
    @IBAction func addBalanceBtnPressed(_ sender: Any) {
        
        let messageAlert: String?
        
        if balanceAmount.text == "Rp0" {
            messageAlert = "Add your business fund"
        }
        else {
            messageAlert = "You've already added business fund"

        }

        let alertController = UIAlertController(title: "Add Balance", message: messageAlert, preferredStyle: .alert)
        
        if balanceAmount.text == "Rp0" {
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let amount = alertController.textFields![0].text
                self.simpleCoreBalance.insert(into: "value", value: amount!)
                self.balanceFetch()
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { alert -> Void in
                //
            })

            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter number"
            }

            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            
            
        }
        else {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { alert -> Void in
                //
            })
            alertController.addAction(okAction)
        }
        
        print(balanceArr)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func balanceFetch(){
        balanceObj = simpleCoreBalance.getData()
        if balanceObj.count > 0 {
            balanceArr.append(balanceObj[0].value(forKey: "value") as! Int)
            balanceAmount.text = numberFormatter.string(from: NSNumber(value: balanceArr[0]))
        }
    }
    
    func cashFlowFetch(){
        cashFlowObj = simpleCoreCashflow.getData()
        for i in 0 ..< cashFlowObj.count {
            cashFlowArr.append(CashFlow(id: cashFlowObj[i].value(forKey: "cashflow_id") as! String, item: cashFlowObj[i].value(forKey: "title") as! String, amount: cashFlowObj[i].value(forKey: "value") as! Int, type: cashFlowObj[i].value(forKey: "type") as! String, date: cashFlowObj[i].value(forKey: "date") as! Date))
        }
    }
    func updateCalculation(){
        cashFlowArr = []
        cashFlowFetch()
        incomeTotal = 0
        spendingTotal = 0
        for i in 0 ..< cashFlowArr.count {
            if cashFlowArr[i].type == "income"{
                incomeTotal = incomeTotal + cashFlowArr[i].amount
            }
            else if cashFlowArr[i].type == "spending" {
                spendingTotal = spendingTotal + cashFlowArr[i].amount
            }
        }
        incomeTotalLabel.text = numberFormatter.string(from: NSNumber(value: incomeTotal))
        spendingTotalLabel.text = numberFormatter.string(from: NSNumber(value: spendingTotal))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AddViewController {
            dest.delegate = self
        }
    }
    

}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cashFlowArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath as IndexPath) as! TableViewCell
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "id_ID")
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        let dateString = df.string(from: cashFlowArr[indexPath.row].date)
        
        let dfTime = DateFormatter()
        dfTime.dateStyle = .none
        dfTime.timeStyle = .short
        let timeString = dfTime.string(from: cashFlowArr[indexPath.row].date)
        let type = cashFlowArr[indexPath.row].type
        cell.titleLabel.text = cashFlowArr[indexPath.row].item
        cell.uuidLabel.text = String(describing: cashFlowArr[indexPath.row].id)
        cell.contentLabel.text = dateString
        cell.contentLabelTwo.text = timeString
        
        if type == "income"{
            cell.labelStatus.text = "+\(numberFormatter.string(from: NSNumber(value: cashFlowArr[indexPath.row].amount))!)"
            cell.labelStatus.textColor = .systemGreen
        }
        else {
            cell.labelStatus.text = "-\(numberFormatter.string(from: NSNumber(value: cashFlowArr[indexPath.row].amount))!)"
            cell.labelStatus.textColor = .systemRed
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
        if editingStyle == .delete {
            simpleCoreCashflow.delete(option: "single", attr: "cashflow_id", value: cell!.uuidLabel.text!)
            print(cell!.uuidLabel.text!)
            cashFlowArr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateCalculation()
        }
    }
    
    
}



extension ViewController : AddViewControllerDelegate {

    func refreshTable(){
        
        DispatchQueue.main.async{
            self.cashFlowArr = []
            self.cashFlowFetch()
            self.noDataLabel.text = ""
            self.incomeTotal = 0
            self.spendingTotal = 0
            for i in 0 ..< self.cashFlowArr.count {
                if self.cashFlowArr[i].type == "income"{
                    self.incomeTotal = self.incomeTotal + self.cashFlowArr[i].amount
                }
                else if self.cashFlowArr[i].type == "spending" {
                    self.spendingTotal = self.spendingTotal + self.cashFlowArr[i].amount
                }
            }
            self.incomeTotalLabel.text = self.numberFormatter.string(from: NSNumber(value: self.incomeTotal))
            self.spendingTotalLabel.text = self.numberFormatter.string(from: NSNumber(value: self.spendingTotal))

            self.tableView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: true)
        }
    }
    
    func refreshBalance(amount: Any) {
        balanceAmount.text = numberFormatter.string(from: amount as! NSNumber)
    }
}

