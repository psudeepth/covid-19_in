//
//  ViewController.swift
//  covid-19 IN
//
//  Created by Deepthu on 24/03/20.
//  Copyright © 2020 sudeepthpatinjarayil. All rights reserved.
//

import UIKit
import SwiftSoup
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var TXT_totalCases: UILabel!
    @IBOutlet weak var TXT_totalCured: UILabel!
    @IBOutlet weak var TXT_totalDead: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    @IBAction func BTN_refresh(_ sender: Any) {
        getData()
    }
    
    func getData() {
        self.TXT_totalCases.text = "0"
        self.TXT_totalCured.text = "0"
        self.TXT_totalDead.text = "0"
        var stateWiseDataDict = [String:String]()
        let url = URL(string: "https://www.mohfw.gov.in")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!)
            }
            else{
                let htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                do {
                    // Reading HTML data for procesing.
                    let doc: Document = try SwiftSoup.parse(htmlContent! as String)
                    // Getting span data for showing output.
                    let span: [Element] = try doc.select("span").array()
                    let totalConfirmed: String = try span[1].text()
                    let totalCured: String = try span[2].text()
                    let totalDead: String = try span[3].text()
                    
                    // Getting state wise data
                    let trData: [Element] = try doc.select("div").array()
                    for each in trData {
                        print(try each.className())
                    }
                                        
                    
                    DispatchQueue.main.async{
                        self.TXT_totalCases.text = totalConfirmed
                        self.TXT_totalCured.text = totalCured
                        self.TXT_totalDead.text = totalDead
                    }
                    
                } catch Exception.Error(type: let type, Message: let message) {
                    print(type)
                    print(message)
                } catch{
                    print("")
                }
            }
            
        }
        task.resume()
    }

}
