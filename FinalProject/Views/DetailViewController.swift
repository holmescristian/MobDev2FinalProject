//
//  DetailViewController.swift
//  FinalProject
//
//  Created by Cristian Holmes on 4/30/19.
//  Copyright © 2019 Cristian Holmes. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DetailViewController: UITableViewController {
    var champId: Int!
    var champName: String!
    var abilityDesc: [String] = []
    var abilityArr: [String] = ["q", "w", "e", "r"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request("http://ddragon.leagueoflegends.com/cdn/6.24.1/data/en_US/champion/" + champName + ".json", method: .get).responseJSON { (responseData) -> Void in
            if(responseData.result.isSuccess) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                for spell in swiftyJsonVar["data"][self.champName]["spells"].arrayValue{
                    if let spell = spell["description"].string{
                        
                        self.abilityDesc.append(spell)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = champName
        label.textColor = UIColor.black
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a new or recycled cell
        
        //CHANGE FROM:
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell",
         for: indexPath)*/
        //TO:
        let cell = tableView.dequeueReusableCell(withIdentifier: "AbilityCell",
                                                 for: indexPath) as! AbilityTableCell
        
        
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the tableview
        if(!abilityDesc.isEmpty){
            let index = indexPath.row
            cell.abilityText.text = abilityDesc[index]
        } else {
            cell.abilityText.text = "Loading..."
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        guard let url = URL(string: "http://stelar7.no/cdragon/latest/abilities/" + String(champId) + "/" +  abilityArr[indexPath.item] + ".png"  ) else { return cell }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Something went wrong: \(error)")
            }
            
            if let imageData = data {
                DispatchQueue.main.async {
                    cell.abilityImage.image = UIImage(data: imageData)
                }
            }
            }.resume()
        
        return cell
    }
}
