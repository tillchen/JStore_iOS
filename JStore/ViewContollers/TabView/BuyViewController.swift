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
import FirebaseFirestoreSwift

class BuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let TAG = "BuyViewController"

    @IBOutlet var mTableView: UITableView!
    
    var mPosts: [Post] = []
    var db: Firestore!
    var mQuery: Query!
    var mLastDocumentSnapShot: DocumentSnapshot!
    var mFetchMore = true
    var mPost: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        mTableView.dataSource = self
        mTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPostID), name: Notification.Name("PostIDReceived"), object: nil)
        
        loadData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        mTableView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func receivedPostID() {
        let postID = UserDefaults.standard.value(forKey: "postID") as? String
        db.collection("posts").document(postID!).getDocument() { (document, error) in
            let result = Result {
                try document.flatMap() {
                    try $0.data(as: Post.self)
                }
            }
            switch result {
            case .success(let JPost):
                if JPost == nil {
                    self.showAlert("Sorry. This post is not in the database.")
                }
                else {
                    print("\(self.TAG) receivedPostID success")
                    self.mPost = JPost
                    self.performSegue(withIdentifier: "PostDetails", sender: nil)
                }
            case .failure(let error):
                print("\(self.TAG) error decoding post \(error)")
                self.showAlert("Sorry. A critical error occured. Please try again or restart the app.")
            }
        }
    }
    
    func loadData() {
        if !mFetchMore {
            return
        }
        if mPosts.isEmpty { // initial load
            print("\(TAG) loadData initial load")
            mQuery = db.collection("posts").whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).limit(to: 10)
        }
        else {
            print("\(TAG) loadData non-initial load")
            mQuery = db.collection("posts").whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).start(afterDocument: mLastDocumentSnapShot).limit(to: 10)
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
        let cell = mTableView.dequeueReusableCell(withIdentifier: "com.tilchen.PostTableViewCell", for: indexPath) as! PostTableViewCell
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
        performSegue(withIdentifier: "PostDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == mPosts.count-1 { // load more data
            loadData()
        }
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) { // TODO
        /*
        mPosts = []
        loadData()
        */
        refreshControl.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! PostDetailsViewController
        viewController.mPost = mPost
    }
    
    @IBAction func unwindToBuy(segue: UIStoryboardSegue) {
        // nothing
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

}

