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
    // Mark: - Constants
    private let defaultBasicCell = "imageDetailVCDefaultBasicCell"
    
    // Mark: - Declarations
    fileprivate enum Sections: Int { case uploader = 0, uploader_description, tag, source, favoraters, comments }
    
    var imageResult: ImageResult!
    var comments: [CommentResult]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 244.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadComments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadComments()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 6
        if imageResult.metadata.description == "" { count -= 1 }
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = sectionForIndex(section) else { return 0 }
        switch section {
        case .uploader: return 1
        case .uploader_description: return 1
        case .tag: return 1
        case .source: return 1
        case .favoraters: return 1
        case .comments: return comments?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = sectionForIndex(indexPath.section) else { return UITableViewCell() }
        switch section {
        case .uploader:
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultBasicCell, for: indexPath)
            cell.backgroundColor = Theme.colors().background
            cell.textLabel?.text = imageResult.metadata.uploader
            return cell
        case .uploader_description:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCTextViewCell.storyboardID, for: indexPath) as! ImageDetailVCTextViewCell
            cell.backgroundColor = Theme.colors().background
            cell.setupLayout()
            cell.setupContent(dataSource: imageResult)
            return cell
        case .tag:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCTagTableCell.storyboardID, for: indexPath) as! ImageDetailVCTagTableCell
            //cell.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 10000) // Forcing the tableview cell to go over so that autolayout will work
            cell.setupLayout(tableView: tableView)
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            /*
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCTagsTextViewCell.storyboardID, for: indexPath) as! ImageDetailVCTagsTextViewCell
            cell.setupLayout()
            cell.setupContent(imageResult: imageResult)
            */
            return cell
        case .source:
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultBasicCell, for: indexPath)
            let text = imageResult.metadata.sourse_url != "" ? imageResult.metadata.sourse_url : "(no source provided)"
            cell.backgroundColor = Theme.colors().background
            cell.textLabel?.text = text
            return cell
        case .favoraters:
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultBasicCell, for: indexPath)
            cell.backgroundColor = Theme.colors().background
            cell.textLabel?.text = "\(imageResult.metadata.faves) \(imageResult.metadata.faves == 1 ? "pony" : "ponies")"
            return cell
        case .comments:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCCommentCell.storyboardID, for: indexPath) as! ImageDetailVCCommentCell
            cell.setupLayout()
            
            guard let count = comments?.count, indexPath.row < count else { return cell }
            cell.setupContent(comment: comments?[count - indexPath.row - 1])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = sectionForIndex(section) else { return "" }
        switch section {
        case .uploader: return "Uploaded by"
        case .uploader_description: return "Uploader Descriptions"
        case .tag: return "Tags"
        case .source: return "Source"
        case .favoraters: return "Favorited by"
        case.comments: return "Comments (\(imageResult.metadata.comment_count))"
        }
    }
    
    // Mark: - Handling Actions
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let section = sectionForIndex(indexPath.section) else { return nil }
        switch section {
        case .uploader: return indexPath
        case .uploader_description: return nil
        case .tag: return nil
        case .source: return indexPath
        case .favoraters: return indexPath
        case .comments: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = sectionForIndex(indexPath.section) else { return }
        switch section {
        case .uploader:
            let url = URL(string: ImageRequester.image_url + "/\(imageResult.metadata.uploader)")
            let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        case .uploader_description: return
        case .tag: return
        case .source:
            let url = URL(string: imageResult.metadata.sourse_url)
            let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        case .favoraters: return
        case .comments: return
        }
    }
    
    @IBAction func openInSafari(_ sender: UIBarButtonItem) {
        let url = URL(string: ImageRequester.image_url + "/\(imageResult.id)")
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    func open(with searchTag: String) {
        #if DEBUG
            print("opening: \(searchTag)")
        #endif
        let listVC = UIStoryboard(name: ListCollectionVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: ListCollectionVC.storyboardID) as! ListCollectionVC
        let dataSource = ListCollectionVM(result: ListResult())
        listVC.dataSource = dataSource
        listVC.title = searchTag
        listVC.isFirstListCollectionVC = false
        listVC.shouldHideNavigationBar = false
        navigationController?.pushViewController(listVC, animated: true)
        listVC.getNewResult(withTags: [searchTag])
    }
    
    // Mark: - Private Methods
    
    private func loadComments() {
        print("Now loading comments")
        
        CommentRequester().downloadComments(for: imageResult.id).then { result -> Void in
            print("dl completed: Count: \(result.count)")
            self.comments = result
            }.then { () -> Void in
                self.tableView.reloadSections(IndexSet(integer: self.sectionIndex(for: .comments)!), with: .automatic)
            }.catch { error in
                print(error)
        }
    }
    
    fileprivate func sectionIndex(for section: Sections) -> Int? {
        switch section {
        case .uploader: return 0
        case .uploader_description: return imageResult.metadata.description != "" ? 1 : nil
        case .tag: return imageResult.metadata.description != "" ? 2 : 1
        case .source: return imageResult.metadata.description != "" ? 3 : 2
        case .favoraters: return imageResult.metadata.description != "" ? 4 : 3
        case .comments: return imageResult.metadata.description != "" ? 5 : 4
        }
    }
    
    fileprivate func sectionForIndex(_ index: Int) -> Sections? {
        switch index {
        case 0: return .uploader
        case 1: return imageResult.metadata.description != "" ? .uploader_description : .tag
        case 2: return imageResult.metadata.description != "" ? .tag : .source
        case 3: return imageResult.metadata.description != "" ? .source : .favoraters
        case 4: return imageResult.metadata.description != "" ? .favoraters : .comments
        case 5: return imageResult.metadata.description != "" ? .comments : nil
        default:
            return nil
        }
    }
}

class ImageDetailVCTextCell: UITableViewCell {
    
    @IBOutlet weak var mainTextView: UITextView!
    
    
}



