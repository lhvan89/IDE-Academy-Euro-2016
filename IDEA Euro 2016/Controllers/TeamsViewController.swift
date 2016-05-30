//
//  TeamsViewController.swift
//  IDEA Euro 2016
//
//  Created by Cuu Long Hoang on 5/30/16.
//  Copyright © 2016 Long Hoang. All rights reserved.
//

import UIKit
import Firebase

class TeamsViewController: UIViewController {

    var database:FIRDatabaseReference!
    var dataList:[[String:[Team]]] = [[String:[Team]]]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.database = FIRDatabase.database().reference()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
//        valueChanged()

    }
    
    func loadData() {
        self.database.child("Groups").queryOrderedByKey().observeEventType(.Value,withBlock: { (snap) in
            if snap.value != nil {
                self.dataList.removeAll()
                if let list = snap.value as? [String:AnyObject] {
                    let sortList = list.sort() { $0.0  < $1.0  }
                    for groupData in sortList {
                        if let teamsData = groupData.1 as? [String:AnyObject] {
                            var teamList:[Team] = [Team]()
                            for teamData in teamsData {
                                var data:[String:AnyObject] = [
                                    "name" : teamData.0
                                ]
                                if let teamInfo = teamData.1 as? [String:AnyObject] {
                                    data["point"] = teamInfo["Point"]
                                    data["rank"] = teamInfo["Rank"]
                                }
                                if let team = Team(data: data) {
                                    teamList.append(team)
                                }
                            }
                            if teamList.count > 0 {
                                let group = [groupData.0:teamList]
                                self.dataList.append(group)
                            }
                            
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }
        })
    }

    func valueChanged() {
        self.database.child("Groups").queryOrderedByKey().observeEventType(.ChildChanged,withBlock: { (snap) in
            if snap.value != nil {
                if let list = snap.value as? [String:AnyObject] {
                    let sortList = list.sort() { $0.0  < $1.0  }
                    for groupData in sortList {
                        if let teamsData = groupData.1 as? [String:AnyObject] {
                            var teamList:[Team] = [Team]()
                            for teamData in teamsData {
                                var data:[String:AnyObject] = [
                                    "name" : teamData.0
                                ]
                                if let teamInfo = teamData.1 as? [String:AnyObject] {
                                    data["point"] = teamInfo["Point"]
                                    data["rank"] = teamInfo["Rank"]
                                }
                                if let team = Team(data: data) {
                                    teamList.append(team)
                                }
                            }
                            if teamList.count > 0 {
                                let group = [groupData.0:teamList]
                                self.dataList.append(group)
                            }
                            
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TeamsViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        for group in self.dataList[section] {
            if let teams:[Team] = group.1 {
                row = teams.count
            }
        }
        return row
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TeamsTableViewCell
        let groups = self.dataList[indexPath.section]
        for group in groups {
            if var teams:[Team] = group.1 {
                teams = teams.sort() { $0.rank < $1.rank }
                let team:Team = teams[indexPath.row]
                let banner:UIImage = UIImage(named: "Banner-\(team.name).jpg")!
                cell.bannerImageView.image = banner
                
                let logo:UIImage = UIImage(named: "\(team.name).png")!
                cell.flagImageView.image = logo
                
                cell.countryLabel.text = team.name
                cell.pointLabel.text = "Điểm số: \(team.point)"
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header = ""
        let groups = self.dataList[section]
        for group in groups {
            header = group.0
        }

        return header
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        let textLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 50, height: 30 ))
        textLabel.font = UIFont(name: "Avenir Next Bold", size: 20)
        textLabel.textColor = UIColor.blueColor()
        let groups = self.dataList[section]
        for group in groups {
            textLabel.text = group.0
            headerView.addSubview(textLabel)
        }
        
        return headerView
    }
}

extension TeamsViewController : UITableViewDelegate {
    
}