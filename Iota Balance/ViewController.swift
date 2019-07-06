//
//  ViewController.swift
//  Iota Balance
//
//  Created by onehitwonder on 10.06.19.
//  Copyright © 2019 onehitwonder. All rights reserved.
//

import UIKit
import Foundation
import Charts


class ViewController: UIViewController, IotaModelProtocol, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, addAdressButtonTapped {
    
    
    
    var checkAdress = IotaModel.adress
    let model = IotaModel()
    var adress = IotaModel.adress
    var balance:Int64 = 0
    var fiat = PriceJson()
    var histroy = [PriceHistoJson]()
    var addAdressVC:AddAdressVC!
    let refreshControlScroll = UIRefreshControl()
    let numberformatter = NumberFormatter()
    var dataEntries: [ChartDataEntry] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var balanceViewIota: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceViewFiat: UILabel!
    @IBOutlet weak var priceViewFiat: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var addAdressButton: UIButton!
    @IBOutlet weak var iotaImage: UIImageView!
    @IBOutlet weak var mChart: LineChartView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set numberformatter to decimal
        numberformatter.numberStyle = .decimal
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        scrollView.delegate = self
        
        model.delegate = self
        
        // Set up AddAdressVC
        addAdressVC = storyboard?.instantiateViewController(withIdentifier: "adressVC") as? AddAdressVC
        addAdressVC.modalPresentationStyle = .overCurrentContext
        addAdressVC.delegate = self
        
        
        // Add Refresh Control to Scroll View
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refreshControlScroll
        } else {
            scrollView.addSubview(refreshControlScroll)
        }
        refreshControlScroll.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        scrollView.isScrollEnabled = true
        self.scrollView.alwaysBounceVertical = true
        
        // Start
        model.getPrice()
        model.getHistoryJson()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
        setUp()
        
    }
    
    @objc private func refreshData(_ sender: Any) {
      
        // Fetch new Data
        model.getBalance()
        model.getPrice()
        model.getHistoryJson()
        
        self.refreshControlScroll.endRefreshing()
        
    }
    
    // Historical Price
    
    func updatePriceHisto(priceHisto: [PriceHistoJson]) {
        
        self.histroy = priceHisto
        let histoRaw = self.histroy[0].Data
        var myArray = [Double]()
        dataEntries.removeAll()
        
        for i in 0..<histoRaw.count {
            
            myArray.append(histoRaw[i].close)
            
        }
        
        setChart(values: myArray)
        self.view.layoutIfNeeded()
        
    }
    
    // Chart
    
    func setChart(values: [Double]) {
        mChart.noDataText = "No data available!"
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let line1 = LineChartDataSet(entries: dataEntries, label: "10 Day Chart")
        line1.setColor(.white, alpha: 0.7)
        line1.mode = .cubicBezier
        line1.cubicIntensity = 0.2
        line1.drawCircleHoleEnabled = false
        line1.drawCirclesEnabled = true
        
        let legend = mChart.legend
        legend.textColor = .white
        legend.drawInside = true
        legend.form = .circle
        
        let gradient = getGradientFilling()
        line1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        line1.drawFilledEnabled = true
        
        let data = LineChartData()
        data.addDataSet(line1)
        mChart.data = data
        mChart.setScaleEnabled(false)
        mChart.animate(xAxisDuration: 0.5)
        mChart.drawGridBackgroundEnabled = false
        mChart.xAxis.drawAxisLineEnabled = false
        mChart.xAxis.drawGridLinesEnabled = true
        mChart.leftAxis.drawAxisLineEnabled = false
        mChart.leftAxis.drawGridLinesEnabled = false
        mChart.rightAxis.drawAxisLineEnabled = false
        mChart.rightAxis.drawGridLinesEnabled = false
        mChart.legend.enabled = true
        mChart.xAxis.enabled = false
        mChart.leftAxis.enabled = false
        mChart.rightAxis.enabled = false
        mChart.xAxis.drawLabelsEnabled = false
        mChart.pinchZoomEnabled = false
        mChart.dragEnabled = false
        mChart.dragDecelerationEnabled = false
        mChart.data?.highlightEnabled = false
        
    }
    
    /// Creating gradient for filling space under the line chart
    private func getGradientFilling() -> CGGradient {
        // Setting fill gradient color
        //let coloTop = UIColor(red: 141/255, green: 133/255, blue: 220/255, alpha: 1).cgColor
        //let colorBottom = UIColor(red: 230/255, green: 155/255, blue: 210/255, alpha: 1).cgColor
        let coloTop = UIColor(red: 120/255, green: 111/255, blue: 187/255, alpha: 1).cgColor
        let colorBottom = UIColor(red: 93/255, green: 121/255, blue: 173/255, alpha: 1).cgColor
        // Colors of the gradient
        let gradientColors = [coloTop, colorBottom] as CFArray
        // Positioning of the gradient
        let colorLocations: [CGFloat] = [0.7, 0.0]
        // Gradient Object
        return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)!
    }
    
    func setUp() {
        
        // If there are addresses to track, call the IotaModel, to get the balance of the addresses
        if IotaModel.adress.isEmpty == false {
            
            model.getBalance()
            
        }
        else {
            
            // Clear the labels if there are no adresses to track
            balanceViewIota.text = "--- MIOTA"
            balanceViewFiat.text = "$ ---"
            priceViewFiat.text = "$ ---"
            
            // Present the addAdress Pop-Up, so the User can enter an address to track
            present(addAdressVC, animated: true, completion: nil)
            
        }
        
    }
    
    // MARK: - Protocol Methods
    
    // Gets called via delegate, when the Node returns the balance of the addresses
    func updateBalance(balance: Int64) {
        
        self.balance = model.userBalance
        
        // Set the text for the balanceView and format the number
        balanceViewIota.text = numberformatter.string(from: NSNumber(value: balance/1000000))!+" MIOTA"
        
        // Call the IotaModel to get the actual price
        
        self.view.layoutIfNeeded()
        
        
    }
    
    func animateLogo() {
        
        // Animation Iota Logo
        UIView.animate(withDuration:0.8, delay: 0, options: .curveEaseInOut,animations: { () -> Void in
            
            self.iotaImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            self.iotaImage.transform = .identity
            self.view.layoutIfNeeded()
            
        })
        
    }
    
    // Gets called via delegate, when the exchange returns the price
    func updatePrice(price: (PriceJson)) {
        
        self.fiat = price
        let roundedBalanceFiat = "$ "+numberformatter.string(from: NSNumber(value:(roundf(100*price.USD! * Float(balance/1000000))/100)))!
        balanceViewFiat.text = roundedBalanceFiat
        priceViewFiat.text = "$ "+numberformatter.string(from: NSNumber(value:price.USD!))!
        
        tableView.reloadData()
        self.view.layoutIfNeeded()
        
        animateLogo()
    
    }
    
    // MARK: - Tableview functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(adress.count)
        return IotaModel.adress.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdressCell", for: indexPath)
        
        // Get the Label
        
        let label = cell.viewWithTag(1) as! UILabel
        
        // Set Text for Label
        label.text = IotaModel.adress[indexPath.row]
        
        return cell
        
    }
    
    // Tableview delete rows
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            IotaModel.adress.remove(at: indexPath.row)
            IotaModel.defaults!.removeObject(forKey: "SavedArray")
            IotaModel.defaults!.set(IotaModel.adress, forKey: "SavedArray")
            tableView.reloadData()
            setUp()
        }
    }
    
    // MARK: - Buttons Action
    
    // Add Adress Button
    @IBAction func actionAddAdress(_ sender: Any) {
        
        present(addAdressVC, animated: true, completion: nil)
        
    }
    
    func addAdressButtonTapped() {
        
        model.getBalance()
        model.getPrice()
    }
    
}

// Extension for dismissing keyboard when tapped somewhere outside

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// Extensions for checking the length of a String and trimming that String

extension String {
    subscript(value: NSRange) -> Substring {
        return self[value.lowerBound..<value.upperBound]
    }
}

extension String {
    subscript(value: CountableClosedRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...index(at: value.upperBound)]
        }
    }
    
    subscript(value: CountableRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...]
        }
    }
    
    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }
}
