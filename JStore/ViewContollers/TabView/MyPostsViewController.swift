//
//  MyPostViewController.swift
//  JStore
//
//  Created by Till Chen on 1/18/20.
//  Copyright © 2020 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseFirestoreSwift

class MyPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource { // TODO: Add scroll to refresh
    
    let TAG = "MyPostViewController"

    @IBOutlet var mTableView: UITableView!
    var mPosts: [Post] = []
    var db: Firestore!
    var mQuery: Query!
    var mLastDocumentSnapShot: DocumentSnapshot!
    var mFetchMore = true
    var mPost: Post!
    var mSold: Bool = false
    var mOwnerID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        mTableView.dataSource = self
        mTableView.delegate = self
        
        loadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func loadData() {
        if !mFetchMore {
            return
        }
        if mPosts.isEmpty { // initial load
            print("\(TAG) loadData initial load")
            if mSold {
                mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: true).order(by: "creationDate", descending: true).limit(to: 10)
            }
            else {
                mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).limit(to: 10)
            }
        }
        else {
            print("\(TAG) loadData non-initial load")
            if mSold {
                mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: true).order(by: "creationDate", descending: true).start(afterDocument: mLastDocumentSnapShot).limit(to: 10)
            }
            else {
                mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).start(afterDocument: mLastDocumentSnapShot).limit(to: 10)
            }
        }
        
        mQuery.getDocuments() { (snapshot, err) in
            if let err = err {
                print("\(self.TAG) loadData error: \(err)")
                self.showAlert("Sorry. Something went wrong. Please try again.")
            }
            else if snapshot!.isEmpty {
                self.mFetchMore = false
                return
            }
            else {
                self.mFetchMore = true
                for document in snapshot!.documents {
                    let result = Result {
                        try document.data(as: Post.self)
                    }
                    switch result {
                    case .success(let post):
                        if let post = post {
                            self.mPosts.append(post)
                        }
                        else {
                            print("\(self.TAG) loadData document doesn't exist")
                        }
                    case .failure(let error):
                        print("\(self.TAG) loadData error: \(error)")
                    }
                }
                self.mTableView.reloadData()
                self.mLastDocumentSnapShot = snapshot!.documents.last
            }
        }
    }

    
    // dataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "com.tilchen.MyPostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = mPosts[indexPath.row]
        cell.mImage.sd_setImage(with: Storage.storage().reference(forURL: post.imageUrl))
        cell.mTitle.text = post.title
        cell.mSeller.text = "by " + post.ownerName
        cell.mPrice.text = "€ " + String(post.price)
        cell.mCategory.text = post.category
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd HH:mm:ss yyyy"
        cell.mDate.text = "Posted at " + dateFormatter.string(from: post.creationDate!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mPost = mPosts[indexPath.row]
        performSegue(withIdentifier: "MyPostDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == mPosts.count-1 { // load more data
            loadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! PostDetailsViewController
        viewController.mPost = mPost
    }
    
    @IBAction func unwindToMyPosts(segue: UIStoryboardSegue) {
        // nothing
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

}

