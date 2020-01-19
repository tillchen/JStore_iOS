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

class MyPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let TAG = "MyPostsViewController"

    @IBOutlet var mTableView: UITableView!
    var mPosts: [Post] = []
    var db: Firestore!
    var mQuery: Query!
    var mLastDocumentSnapShot: DocumentSnapshot!
    var isMoreDataLoading : Bool = false
    var mPost: Post!
    var mSold: Bool = false
    var mOwnerID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        mTableView.dataSource = self
        mTableView.delegate = self
        
        initialLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        mTableView.insertSubview(refreshControl, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("RefreshMyPosts"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func initialLoad() {
        if mSold {
            mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: true).order(by: "creationDate", descending: true).limit(to: 10)
        }
        else {
            mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).limit(to: 10)
        }
        fetchPostsFromDB()
    }
    
    func loadMoreData() {
        if mLastDocumentSnapShot == nil {
            return
        }
        if mSold {
            mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: true).order(by: "creationDate", descending: true).start(afterDocument: mLastDocumentSnapShot).limit(to: 10)
        }
        else {
            mQuery = db.collection("posts").whereField("ownerId", isEqualTo: mOwnerID).whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).start(afterDocument: mLastDocumentSnapShot).limit(to: 10)
        }
        fetchPostsFromDB()
    }
    
    func fetchPostsFromDB() {
        mQuery.getDocuments() { (snapshot, err) in
            if let err = err {
                print("\(self.TAG) loadData error: \(err)")
                self.showAlert("Sorry. Something went wrong. Please try again.")
            }
            else if snapshot!.isEmpty {
                self.isMoreDataLoading = false
                return
            }
            else {
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
                self.isMoreDataLoading = false
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
        if mPosts.count == 0 {
            return cell
        }
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
        if mPosts.count == 0 {
            return
        }
        mPost = mPosts[indexPath.row]
        performSegue(withIdentifier: "MyPostDetails", sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMoreDataLoading {
            let scrollViewContentHeight = mTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - mTableView.bounds.size.height
            if scrollView.contentOffset.y > scrollOffsetThreshold && mTableView.isDragging {
                isMoreDataLoading = true
                loadMoreData()
            }
            
        }
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        mPosts = []
        initialLoad()
        refreshControl.endRefreshing()
    }
    
    @objc func refresh() {
        mPosts = []
        initialLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! PostDetailsViewController
        viewController.mPost = mPost
        viewController.mFromBuyViewController = false
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

