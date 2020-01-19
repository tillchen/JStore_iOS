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

class BuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    let TAG = "BuyViewController"

    @IBOutlet var mTableView: UITableView!
    @IBOutlet var mFilterTextField: UITextField!
    @IBOutlet var mCategoryTextField: UITextField!
    
    var mPosts: [Post] = []
    var db: Firestore!
    var mQuery: Query!
    var mLastDocumentSnapShot: DocumentSnapshot!
    var isMoreDataLoading = false
    var mPost: Post!
    
    let mCategories = ["Apparel, Shoes & Watches", "Automotive, Motorcycle & Industrial", "Beauty & Health", "Books & Audible", "Electronics & Computers", "Grocery/Food", "Home, Garden, Pets & DIY", "Automotive, Motorcycle & Industrial", "Sports & Outdoors", "Other"]
    let mFilters = ["Date↓", "Date↑", "Price↑", "Price↓"]
    let FILTER_PICKER = 0
    let CATEGORY_PICKER = 1
    let mFilterPicker = UIPickerView()
    let mCategoryPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        initUIAndObservers()
        
        initialLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func initUIAndObservers() {
        mTableView.dataSource = self
        mTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPostID), name: Notification.Name("PostIDReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("RefreshBuy"), object: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        mTableView.insertSubview(refreshControl, at: 0)
        
        mFilterPicker.delegate = self
        mFilterPicker.dataSource = self
        mFilterPicker.tag = FILTER_PICKER
        mCategoryPicker.delegate = self
        mCategoryPicker.dataSource = self
        mCategoryPicker.tag = CATEGORY_PICKER
        mFilterTextField.inputView = mFilterPicker
        mCategoryTextField.inputView = mCategoryPicker
        mFilterTextField.text = mFilters[0] // default
        mCategoryTextField.text = mCategories[0] // default
    }
    
    func initialLoad() {
        mQuery = db.collection("posts").whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).limit(to: 10)
        fetchPostsFromDB()
    }
    
    func loadMoreData() {
        if mLastDocumentSnapShot == nil {
            return
        }
        mQuery = db.collection("posts").whereField("sold", isEqualTo: false).order(by: "creationDate", descending: true).start(afterDocument: mLastDocumentSnapShot).limit(to: 10)
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
    
    // dataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "com.tilchen.PostTableViewCell", for: indexPath) as! PostTableViewCell
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
        performSegue(withIdentifier: "PostDetails", sender: nil)
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
        viewController.mFromBuyViewController = true
    }
    
    @IBAction func unwindToBuy(segue: UIStoryboardSegue) {
        // nothing
    }
    
    // For the pickers:
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == CATEGORY_PICKER {
            return mCategories.count
        }
        else { // Filter Picker
            return mFilters.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == CATEGORY_PICKER {
            return mCategories[row]
        }
        else { // CONDITION_PICKER
            return mFilters[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == CATEGORY_PICKER {
            mCategoryTextField.text = mCategories[row]
        }
        else { // CONDITION_PICKER
            mFilterTextField.text = mFilters[row]
        }
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

}

