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
    
    // Mark: - Properties
    
    var imageResult: ImageResult!
    var comments: [CommentResult]?
    
    // TODO: - Screen rotation breaks tag collection row height
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 244.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        
        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadComments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadComments()
    }
    
    // TODO: - Fix collectionview rotation issue
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let section = sectionIndex(for: .tag), let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? ImageDetailVCTagTableCell {
            cell.collectionView.collectionViewLayout.invalidateLayout()
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCLabelCell.storyboardID, for: indexPath) as! ImageDetailVCLabelCell
            cell.formatTheme()
            cell.selectionStyle = .none
            cell.setupLayout()
            cell.setupContent(text: "\(imageResult.metadata.uploader)")
            return cell
        case .uploader_description:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCTextViewCell.storyboardID, for: indexPath) as! ImageDetailVCTextViewCell
            cell.formatTheme()
            cell.setupLayout()
            cell.setupContent(dataSource: imageResult)
            return cell
        case .tag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCTagTableCell.storyboardID, for: indexPath) as! ImageDetailVCTagTableCell
            cell.formatTheme()
            cell.setupLayout(tableView: tableView)
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            return cell
        case .source:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCLabelCell.storyboardID, for: indexPath) as! ImageDetailVCLabelCell
            cell.formatTheme()
            cell.selectionStyle = .none
            cell.setupLayout()
            let text = imageResult.metadata.source_url != "" ? imageResult.metadata.source_url : "(no source provided)"
            cell.setupContent(text: text)
            return cell
        case .favoraters:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCLabelCell.storyboardID, for: indexPath) as! ImageDetailVCLabelCell
            cell.formatTheme()
            cell.selectionStyle = .none
            cell.setupLayout()
            cell.setupContent(text: "\(imageResult.metadata.faves) \(imageResult.metadata.faves == 1 ? "pony" : "ponies")")
            return cell
        case .comments:
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageDetailVCCommentCell.storyboardID, for: indexPath) as! ImageDetailVCCommentCell
            cell.formatTheme()
            cell.setupLayout()
            
            guard let count = comments?.count, indexPath.row < count else { return cell }
            cell.setupContent(comment: comments?[count - indexPath.row - 1], indexPath: indexPath)
            return cell
        }
    }
    
    // TODO: - Make it compatible with iPhone X, currently header view is not using autolayout
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = Bundle.main.loadNibNamed("ImageDetailVCHeaderView", owner: nil, options: nil)?.first as? ImageDetailVCHeaderView else { return UIView() }
        view.setupLayout()
        
        if let section = sectionForIndex(section) {
            switch section {
            case .uploader: view.mainLabel.text = "Uploaded by"
            case .uploader_description: view.mainLabel.text = "Uploader Descriptions"
            case .tag: view.mainLabel.text = "Tags"
            case .source: view.mainLabel.text = "Source"
            case .favoraters: view.mainLabel.text = "Favorited by"
            case.comments: view.mainLabel.text = "Comments (\(imageResult.metadata.comment_count))"
            }
        } else {
            view.mainLabel.text = ""
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 44 }
    
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
            guard let uploader_id = imageResult.metadata.uploader_id else {
                tableView.deselectRow(at: indexPath, animated: true)
                break
            }
            let url = URL(string: Requester.base_url + "/profiles/\(uploader_id)")
            let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
            svc.delegate = self
            if #available(iOS 10, *) {
                svc.preferredBarTintColor = Theme.colors().background_header
                svc.preferredControlTintColor = Theme.colors().labelText
            }
            
            self.present(svc, animated: true, completion: nil)
        case .uploader_description: return
        case .tag: return
        case .source:
            let url = URL(string: imageResult.metadata.source_url)
            let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
            svc.delegate = self
            if #available(iOS 10, *) {
                svc.preferredBarTintColor = Theme.colors().background_header
                svc.preferredControlTintColor = Theme.colors().labelText
            }

            self.present(svc, animated: true, completion: nil)
        case .favoraters: return
        case .comments: return
        }
    }
    
    // MARK: - Share Sheet
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        
    }
    
    func openInSafari() {
        let url = URL(string: ImageRequester.image_url + "/\(imageResult.id)")
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        if #available(iOS 10, *) {
            svc.preferredBarTintColor = Theme.colors().background_header
            svc.preferredControlTintColor = Theme.colors().labelText
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    func open(with searchTag: String) {
        #if DEBUG
            print("opening: \(searchTag)")
        #endif
        SearchManager.main.appendSearch(SearchManager.SearchHistory(timeStamp: Date(), searchString: searchTag, sortFilter: SortFilter(sortBy: .creationDate, sortOrder: .descending)))
        
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
        CommentRequester().downloadComments(for: imageResult.id).then { result -> Void in
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

extension UITableViewCell {
    
    func formatTheme() {
        backgroundColor = Theme.colors().background
    }
    
}



