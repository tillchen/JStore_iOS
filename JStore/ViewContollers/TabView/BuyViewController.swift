//
//  FirstViewController.swift
//  JStore
//
//  Created by Till Chen on 12/5/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class BuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let TAG = "BuyViewController"

    @IBOutlet var mTableView: UITableView!
    
    var mPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mTableView.dataSource = self
        mTableView.delegate = self
    }
    
    // dataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "com.tilchen.PostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = mPosts[indexPath.row]
        cell.mImage.sd_setImage(with: Storage.storage().reference(forURL: post.imageUrl))
        cell.mTitle.text = post.title
        cell.mSeller.text = "by " + post.ownerName
        cell.mPrice.text = "€ " + String(post.price)
        cell.mCategory.text = post.category
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd HH:mm:ss yyyy"
        cell.mDate.text = dateFormatter.string(from: post.creationDate!)
        return cell
    }

}

