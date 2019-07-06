//
//  PriceJson.swift
//  Iota Balance
//
//  Created by onehitwonder on 10.06.19.
//  Copyright © 2019 onehitwonder. All rights reserved.
//

import Foundation

struct PriceJson:Decodable {
    
    var USD:Float?
    var EUR:Float?
    
}



struct PriceHistoJson:Decodable {
    
    let Response: String
    let `Type`: Int
    let Aggregated: Bool
    let Data:[DataHisto]
    let TimeTo: Int
    let TimeFrom: Int
    let FirstValueInArray: Bool
    
    
}

struct DataHisto: Decodable {
    let time: Double
    let close: Double
    let high: Double
    let low: Double
    let open: Double
    let volumefrom: Double
    let volumeto: Double
}


