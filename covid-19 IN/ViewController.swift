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
    
    private let locationManager = LocationManager()
    
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
        
        var stateWiseDataDict = [String:[String:String]]()
        
        let url = URL(string: "https://www.mohfw.gov.in")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!)
            }
            else{
                let htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                var totalConfirmed: String = ""
                var totalCured: String = ""
                var totalDead: String = ""
                do {
                    // Reading HTML data for procesing.
                    let doc: Document = try SwiftSoup.parse(htmlContent! as String)
                    
                    // Getting state wise data and adding it to dictionary
                    let tables: [Element] = try doc.select("tbody").array()
                    let tr = try tables[7].getElementsByTag("tr")
                    for eachTR in tr{
                        let td = try eachTR.getElementsByTag("td")
                        let checkEntry: String = try td.text().components(separatedBy: " ")[0]
                        if Int(checkEntry) != nil
                        {
                            stateWiseDataDict[try td[1].text()] = ["totalPositive": try td[2].text(), "totalCured": try td[4].text(), "totalDeaths": try td[5].text()]
                        }
                        else
                        {
                            if try td.text().components(separatedBy: " ")[0] == "Total"
                            {
                                totalConfirmed = try td[1].text()
                                totalCured = try td[3].text()
                                totalDead = try td[4].text()
                            }
                        }
                    }
                    
                    // Setting the display labels
                    DispatchQueue.main.async{
                        self.TXT_totalCases.text = totalConfirmed
                        self.TXT_totalCured.text = totalCured
                        self.TXT_totalDead.text = totalDead
                    }
                    
                    for eachState in stateWiseDataDict.keys
                    {
                        self.locationManager.getLocation(forPlaceCalled: eachState)
                        {
                            location in guard let location = location else { return }
                            let lat: Double = location.coordinate.latitude
                            let lon: Double =  location.coordinate.longitude
                            let annotation = MKPointAnnotation()
                            annotation.title = eachState
                            let statePositive: String = stateWiseDataDict[eachState]!["totalPositive"]!
                            let stateStateCured: String = stateWiseDataDict[eachState]!["totalCured"]!
                            let stateDeath: String = stateWiseDataDict[eachState]!["totalDeaths"]!
                            annotation.subtitle = "Positive: \(statePositive), Cured: \(stateStateCured), Death: \(stateDeath)"
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            self.mapView.addAnnotation(annotation)
                        }
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
