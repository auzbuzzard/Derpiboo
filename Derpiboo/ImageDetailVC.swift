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
    
    @IBAction func openInSafari(_ sender: UIBarButtonItem) {
        let u = ImageRequester.image_url + "/\(imageResult.id)"
        let url = URL(string: u)
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    var imageResult: ImageResult!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 1
        default: return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! ImageDetailVCTextCell
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(tagIsTapped(sender:)))
            singleTap.numberOfTapsRequired = 1
            cell.mainTextView.addGestureRecognizer(singleTap)
            
            let tagAttrString = NSMutableAttributedString(string: imageResult.metadata.tags)
            tagAttrString.addAttribute(NSForegroundColorAttributeName, value: Theme.colors().labelText, range: NSMakeRange(0, tagAttrString.length))
            tagAttrString.addAttribute(NSFontAttributeName, value: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body), range: NSMakeRange(0, tagAttrString.length))
            
            cell.mainTextView.attributedText = tagAttrString
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! ImageDetailVCTextCell
            
            return cell
            
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Tags"
        case 1: return "Statistics"
        default: return nil
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tagIsTapped(sender: UITapGestureRecognizer) {
        if let mainTextView = sender.view as? UITextView {
            let point = sender.location(in: mainTextView)
            let position = mainTextView.closestPosition(to: point)
            if let range = mainTextView.tokenizer.rangeEnclosingPosition(position!, with: .word, inDirection: 1) {
                
                var startIndex = mainTextView.offset(from: mainTextView.beginningOfDocument, to: range.start)
                var endIndex = mainTextView.offset(from: mainTextView.beginningOfDocument, to: range.end)
                
                //print("range: \(range)")
                
                //looking forwards
                
                //print("length: \(mainTextView.attributedText.length)")
                //print("ok: \(mainTextView.position(from: mainTextView.beginningOfDocument, offset: endIndex)), endIndex: \(endIndex), length: \(mainTextView.attributedText.length)")
                
                while true {
                    guard let _ = mainTextView.position(from: mainTextView.beginningOfDocument, offset: endIndex + 1) else {
                        endIndex -= 1
                        break
                    }
                    if endIndex >= mainTextView.attributedText.length {
                        endIndex = mainTextView.attributedText.length - 1
                        break
                    }
                    let endCharacter = mainTextView.attributedText.attributedSubstring(from: NSMakeRange(endIndex, 1))
                    //print("endIndex: \(endIndex), char: \(endCharacter.string)")
                    if endCharacter.string != "," && endIndex < mainTextView.attributedText.length - 1 {
                        endIndex += 1
                    } else {
                        endIndex -= 1
                        break
                    }
                }
                
                ////looking backwards
                
                while true {
                    guard let _ = mainTextView.position(from: mainTextView.beginningOfDocument, offset: startIndex - 1) else { break }
                    let startCharacter = mainTextView.attributedText.attributedSubstring(from: NSMakeRange(startIndex, 1))
                    //print("startIndex: \(startIndex), char: \(startCharacter.string)")
                    if startCharacter.string != "," && startIndex != 0 {
                        startIndex -= 1
                    } else {
                        startIndex += 1
                        break
                    }
                }
                
                //print("final: \(startIndex), \(endIndex - startIndex + 1)")
                
                let word = mainTextView.attributedText.attributedSubstring(from: NSMakeRange(startIndex, endIndex - startIndex + 1))
                
                //print("word: \(word.string), word length: \(word.length)")
                
                open(withSearchTag: word.string)
            }
        }
    }
    
    var searchDelegate: SearchManager?
    
    func open(withSearchTag tag: String) {
        searchDelegate = SearchManager()
        searchDelegate?.searchString = tag
        let listVC = storyboard?.instantiateViewController(withIdentifier: "listCollectionVC") as! ListCollectionVC
        listVC.delegate = searchDelegate
        listVC.isFirstListVC = false
        listVC.title = tag
        navigationController?.pushViewController(listVC, animated: true)
        
    }

}

class ImageDetailVCTextCell: UITableViewCell {
    
    @IBOutlet weak var mainTextView: UITextView!
    
    
}



