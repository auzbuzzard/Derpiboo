//
//  ImageDetailVC.swift
//  e926
//
//  Created by Austin Chau on 10/10/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit
import SafariServices

class ImageDetailVC: UITableViewController, SFSafariViewControllerDelegate {
    
    // Mark: - Declarations
    fileprivate enum Sections: Int { case tag = 0 }
    
    var imageResult: ImageResult!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 244.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { return 0 }
        switch section {
        case .tag: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Sections(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .tag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCTagTableCell.storyboardID, for: indexPath) as! ImageDetailVCTagTableCell
            
            cell.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 10000) // Forcing the tableview cell to go over so that autolayout will work
            cell.setupLayout(tableView: tableView)
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return "" }
        switch section {
        case .tag: return "Tags"
        }
    }
    
    // Mark: - Handling Actions
    
    @IBAction func openInSafari(_ sender: UIBarButtonItem) {
        let u = ImageRequester.image_url + "/\(imageResult.id)"
        let url = URL(string: u)
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    func open(with searchTag: String) {
        #if DEBUG
            print("opening: \(searchTag)")
        #endif
        let listVC = storyboard?.instantiateViewController(withIdentifier: ListCollectionVC.storyboardID) as! ListCollectionVC
        let dataSource = ListCollectionVM(result: ListResult())
        listVC.dataSource = dataSource
        listVC.title = searchTag
        listVC.isFirstListCollectionVC = false
        listVC.shouldHideNavigationBar = false
        navigationController?.pushViewController(listVC, animated: true)
        listVC.getNewResult(withTags: [searchTag])
    }
}

class ImageDetailVCTextCell: UITableViewCell {
    
    @IBOutlet weak var mainTextView: UITextView!
    
    
}



