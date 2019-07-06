//
//  IotaModel.swift
//  Iota Balance
//
//  Created by onehitwonder on 10.06.19.
//  Copyright © 2019 onehitwonder. All rights reserved.
//

import Foundation
import IotaKit
import Dispatch

protocol IotaModelProtocol {
    
    func updateBalance(balance:Int64)
    func updatePrice(price:(PriceJson))
    func updatePriceHisto(priceHisto:[PriceHistoJson])
    
}


class IotaModel {
    
    let iota = Iota(node: "https://nodes.thetangle.org", port: 443)
    var resultOfAdress = [String:Int64]()
    static let defaults = UserDefaults(suiteName: "group.olaf.hoops.iota")
    static var adress:[String] = defaults!.stringArray(forKey: "SavedArray") ?? [String]()
 
    
    var userBalance:Int64 = 0
    var delegate:IotaModelProtocol?
    
    func getBalance() {
        
        // Update addresses from UserDefaults
        IotaModel.adress = IotaModel.defaults!.stringArray(forKey: "SavedArray") ?? [String]()
        
        // Clear everything
        resultOfAdress = ["":0]
        userBalance = 0
        callNodeForBalance()
        
    }
    
    func getPrice() {
        getRemoteJsonFile()
    }
    
    func callNodeForBalance() {
        
        iota.balances(addresses: IotaModel.adress, { (sucess) in
            
            self.resultOfAdress = sucess
            
            for (_,value) in self.resultOfAdress {
                
                self.userBalance += value
                
                DispatchQueue.main.async {
                    self.delegate?.updateBalance(balance: self.userBalance)
                }
                
            }
        }) { (error) in
            
            print("Got following error while trying to fetch balance: \(error)")
            
        }
       
    } // End of call Node for Balance
    
    
    func getRemoteJsonFile() {
        
        
        // Create URL Object
        let stringURL = "https://min-api.cryptocompare.com/data/price?fsym=MIOTA&tsyms=USD,EUR,.json"
        
        let url = URL(string: stringURL)
        
        guard url != nil else {
            print("URL Object is nil")
            return
        }
        
        // Get URL Session Object
        let urlSession = URLSession.shared
        
        
        // Get DataTask Object
        let dataTask = urlSession.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                do {
                    // Create json decoder
                    let decoder = JSONDecoder()
                    
                    // Try to parse the data
                    let array = try decoder.decode((PriceJson).self, from: data!)
                    
                    // Give data to ViewController by passing data from a background thread back to the main thread
                    DispatchQueue.main.async {
                        self.delegate?.updatePrice(price: array)
                    }
                    
                    
                }
                catch {
                    print("Error while decoding json Data from web")
                }
            }
            
        }
        
        // Call resume on the DataTask Object
        dataTask.resume()
        
    }
    
    func getHistoryJson() {
        
        
        // Create URL Object
        let stringURL = "https://min-api.cryptocompare.com/data/histoday?fsym=MIOTA&tsym=USD&limit=9"
        
        let url = URL(string: stringURL)
        
        guard url != nil else {
            print("URL Object is nil")
            return
        }
        
        // Get URL Session Object
        let urlSession = URLSession.shared
        
        
        // Get DataTask Object
        let dataTask = urlSession.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                do {
                    // Create json decoder
                    let decoder = JSONDecoder()
                    
                    // Try to parse the data
                    let array = try decoder.decode((PriceHistoJson).self, from: data!)
                    
                    // Give data to ViewController by passing data from a background thread back to the main thread
                    DispatchQueue.main.async {
                        self.delegate?.updatePriceHisto(priceHisto: [array])
                    }
                    
                    
                }
                catch {
                    print("Error while decoding json Data from web")
                }
            }
            
        }
        
        // Call resume on the DataTask Object
        dataTask.resume()
        
    }
    
}

