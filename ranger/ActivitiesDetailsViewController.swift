//
//  ActivitiesDetailsViewController.swift
//  ranger
//
//  Created by Takashi Wickes on 4/24/16.
//  Copyright © 2016 TrailHacks_Ranger. All rights reserved.
//

import UIKit

class ActivitiesDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var passedList: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        print(passedList)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leavingView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        if passedList != nil {
            return passedList!.count
        } else {
            return 0
        }
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! ActivitiesDetailsTableViewCell
        cell.detailsLabel!.text = passedList![indexPath.row]
        cell.imageDetail.image = UIImage(named: passedList![indexPath.row])
        
        cell.imageBack.layer.cornerRadius = cell.imageBack.frame.width / 4
        cell.imageBack.backgroundColor = UIColor(red:0.71, green:0.79, blue:0.51, alpha:1.0)
        
        return cell
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
