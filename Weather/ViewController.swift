//
//  ViewController.swift
//  Weather
//
//  Created by Daniil Aleshchenko on 27.03.2022.
//

import UIKit

class ViewController: UIViewController {

	
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var searchBar: UISearchBar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchBar.delegate = self
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}


}

extension ViewController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		searchBar.resignFirstResponder()
		
		
		// Сreate URL response
		// Adding "%20" instead of a space in the city name
		let urlString = "http://api.weatherstack.com/current?access_key=205b15f2c3a481b011ee3c078fcb8e55&query=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))"
		
		// URL check just in case
		guard let url = URL(string: urlString) else { return cityLabel.text = "Invalid request" }
		
		// Variables
		var locationName: String?
		var temperature: Double?
		var errorHasOccured: Bool = false
		
		// API response
		let task = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
			do {
				let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
				
				// Error
				if let _ = json["error"] {
					errorHasOccured = true
				}
				
				// Main data
				if let location = json["location"] {
					locationName = location["name"] as? String
				}
				
				if let current = json["current"] {
					temperature = current["temperature"] as? Double
				}
				
				// We throw everything into the main thread and, if an error occurs, we display an unpleasant message
				DispatchQueue.main.async {
					if errorHasOccured {
						self?.temperatureLabel.isHidden = true
						self?.cityLabel.text = "Oops, you've made a mistake"
					} else {
						self?.cityLabel.text = locationName
						self?.temperatureLabel.text = "\(temperature!) ℃"
						self?.temperatureLabel.isHidden = false
					}
				}
				
			}
			// We catch the JSON error and output it to the terminal
			catch let jsonError {
				print(jsonError)
			}
		}
		
		// Request execution
		task.resume()
	}
}
