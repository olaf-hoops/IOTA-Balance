//
//  TodayViewController.swift
//  IOTA Widget
//
//  Created by onehitwonder on 19.06.19.
//  Copyright © 2019 onehitwonder. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, IotaModelProtocol {
    
    
    
    let model = IotaModel()
    var fiat = PriceJson()
    var balance:Int64 = 0
    let numberformatter = NumberFormatter()
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        numberformatter.numberStyle = .decimal
        
        model.delegate = self
        
 
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
       
        
        model.getBalance()
        
        // If there's an update, use NCUpdateResult.NewData
 
        completionHandler(NCUpdateResult.newData)
    }
    
    func updateBalance(balance: Int64) {
        
        self.balance = model.userBalance
        
        print("delegate one works")
        
        balanceLabel.text = numberformatter.string(from: NSNumber(value: balance/1000000))!+" MIOTA"
        model.getPrice()
        
        self.view.layoutIfNeeded()
        
    }
    
    func updatePrice(price: (PriceJson)) {
        
        print("delegate two works")
        self.fiat = price
        let roundedBalanceFiat = "$ "+numberformatter.string(from: NSNumber(value:(roundf(100*price.USD! * Float(balance/1000000))/100)))!
        usdLabel.text = roundedBalanceFiat
        priceLabel.text = "$ "+numberformatter.string(from: NSNumber(value:price.USD!))!
        self.view.layoutIfNeeded()
        
        print(self.balance)
        print(price.USD!)
        print("\((price.USD! * Float(balance/1000000)).description) USD")
        
    }
    
}
