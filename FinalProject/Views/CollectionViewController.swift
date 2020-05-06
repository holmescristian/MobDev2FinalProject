//
//  CollectionViewController.swift
//  FinalProject
//
//  Created by Cristian Holmes on 4/29/19.
//  Copyright © 2019 Cristian Holmes. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "champCell"
    var cellColor = true
    var arrRes: [String] = []
    var champArray: [String:[String:Any]] = [:]
    var champIds: [Int: String] = [:]
    let headers : HTTPHeaders = ["X-Riot-Token": "RGAPI-c48a52c3-28bf-41ac-b73e-84561dbe4f2e"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        Alamofire.request("http://ddragon.leagueoflegends.com/cdn/9.7.1/data/en_US/champion.json", method: .get).responseJSON { (responseData) -> Void in
            if(responseData.result.isSuccess) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                for (key, json) in swiftyJsonVar["data"].dictionaryValue{
                    self.champArray[key] = json.dictionary! as Dictionary<String, AnyObject>
                    if let id = json.dictionaryValue["key"]?.intValue{
                        self.champIds[id] = key
                    }
                    
                }
            }
        }
        
        Alamofire.request("https://na1.api.riotgames.com/lol/platform/v3/champion-rotations", method: .get, headers: headers).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                for item in swiftyJsonVar["freeChampionIds"]{
                    if let integerValue = item.1.number?.stringValue {
                        self.arrRes.append(integerValue)
                    }
                }
                
                if self.arrRes.count > 0 {
                    self.collectionView.reloadData()
                }
            }
        }
       
        // Register cell classes
        self.collectionView!.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrRes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
        
        // Configure the cell
        // 3
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        guard let url = URL(string: "http://stelar7.no/cdragon/latest/champion-icons/" + arrRes[indexPath.item] + ".png"  ) else { return cell }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Something went wrong: \(error)")
            }
            
            if let imageData = data {
                DispatchQueue.main.async {
                    cell.champImage.image = UIImage(data: imageData)
                }
            }
            }.resume()
        
        cell.tag = indexPath.item
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the "showItem" segue
        if let cell = sender as? MenuCollectionViewCell
        {
            let destinationViewController = segue.destination as! DetailViewController
            destinationViewController.champId = Int(arrRes[cell.tag])
            if let champId = Int(arrRes[cell.tag]){
                destinationViewController.champName = champIds[champId]
            }
            
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
