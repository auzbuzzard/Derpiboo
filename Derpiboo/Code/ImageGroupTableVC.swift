//
//  ImageGroupTableVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageGroupTableVC: UITableViewController {
    
    private let cellReuseIdentifier = "groupTableCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.backgroundColor = Utils.color().background
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        let derpibooru = Derpibooru()
        let index = indexPath.row
        let listName = index == 0 ? "top_scoring" : index == 1 ? "top_commented" : "all_time_top_scoring"
        derpibooru.setDBToLoadingList(listName)
        
        let groupVC = storyboard?.instantiateViewControllerWithIdentifier("ImageGroupVC") as! ImageGroupVC
        
        groupVC.derpibooru = derpibooru
        
        cell.contentView.addSubview(groupVC.view)
        cell.sizeToFit()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}