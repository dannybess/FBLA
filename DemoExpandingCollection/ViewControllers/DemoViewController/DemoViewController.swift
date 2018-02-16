//
//  DemoViewController.swift
//  TestCollectionView
//
//  Created by Alex K. on 12/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit
import AABlurAlertController
import Firebase

// to convert string to bool to deal with type shifting
// from firebase to client
extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

// define class specific variables
class DemoViewController: ExpandingViewController {
    
    fileprivate var cellsIsOpen = [Bool]()
    fileprivate var items : [Book] = []
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet var pageLabel: UILabel!
    
    // search button clicked; handle events
    @IBAction func searchClicked(_ sender: Any) {
        
    }
}

// lifecycle functinos; call networking functions and setup view
extension DemoViewController {

    override func viewDidLoad() {
        itemSize = CGSize(width: 256, height: 460)
        super.viewDidLoad()

        registerCell()
        addGesture(to: collectionView!)
        configureNavBar()
        loadBooks()
        loadUserInventory()
        fillCellIsOpenArray()
    }
}

// helper functions for collection view and networking
extension DemoViewController {

    fileprivate func registerCell() {
        let nib = UINib(nibName: String(describing: DemoCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: DemoCollectionViewCell.self))
    }

    // fill array with empty values
    fileprivate func fillCellIsOpenArray() {
        cellsIsOpen = Array(repeating: false, count: items.count)
    }

    fileprivate func getViewController() -> ExpandingTableViewController {
        let storyboard = UIStoryboard(storyboard: .Main)
        let toViewController: DemoTableViewController = storyboard.instantiateViewController()
        return toViewController
    }

    fileprivate func configureNavBar() {
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
    
    // load books from firebase
    fileprivate func loadBooks() {
        var ref = Database.database().reference()
        ref.child("library").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let values = snapshot.value as? NSDictionary
            for (key, val) in values! {
                let dict = val as! NSDictionary
                let name = dict["name"] as! String
                let author = dict["author"] as! String
                let checkedout = dict["checkedout"] as! Int
                let count = dict["count"] as! Int
                let reserved = dict["reserved"] as! Int
            
                
                var book = Book(name: name, author: author, checkedout: Int(checkedout), reserved: Int(reserved), bookID: key as! String, count: Int(count))
                // add book
                self.items.append(book)
                // handle UI
                self.fillCellIsOpenArray()
                // reload collection view
                self.collectionView?.reloadData()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // load user inventory from firebase
    fileprivate func loadUserInventory() {
        let ref = Database.database().reference()
        ref.child("users").child(user.schoolID).child("books").observeSingleEvent(of: .value, with: { (snapshot) in
            // check if user even exists
            if let values = snapshot.value as? NSDictionary {
                for (key, val) in values {
                    let dict = val as! NSDictionary
                    let bookid = key as! String
                    let checkedout = dict["checkedout"] as! Bool
                    let isReserved = dict["reserved"] as! Bool
                    let date = dict["date"] as! String
                    let isCheckedOut = dict["checkedout"] as! Bool
                    
                    // add book to User object
                    user.books.append(Book(bookID: bookid, isReserved: isReserved, isCheckedOut: isCheckedOut, date: date))
                    self.collectionView?.reloadData()
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // check if user has a book by ID
    func checkIfInInventory(bookId : String) -> Book? {
        for book in user.books {
            if(book.bookID == bookId) {
                return book
            }
        }
        return nil
    }
    
    
}

// helper functions for gesture control
extension DemoViewController {

    fileprivate func addGesture(to view: UIView) {
        let upGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(DemoViewController.swipeHandler(_:)))) {
            $0.direction = .up
        }

        let downGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(DemoViewController.swipeHandler(_:)))) {
            $0.direction = .down
        }
        view.addGestureRecognizer(upGesture)
        view.addGestureRecognizer(downGesture)
    }

    @objc func swipeHandler(_ sender: UISwipeGestureRecognizer) {
        let indexPath = IndexPath(row: currentIndex, section: 0)
        guard let cell = collectionView?.cellForItem(at: indexPath) as? DemoCollectionViewCell else { return }
        
        // single swipe up
        let open = sender.direction == .up ? true : false
        cell.cellIsOpen(open)
        cellsIsOpen[indexPath.row] = cell.isOpened
    }
}

// scroll view delegate
extension DemoViewController {

    func scrollViewDidScroll(_: UIScrollView) {
        pageLabel.text = "\(currentIndex + 1)/\(items.count)"
    }
}


// data source delegate
extension DemoViewController {

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        guard let cell = cell as? DemoCollectionViewCell else { return }

        // get book at index
        let index = indexPath.row % items.count
        let info = items[index]
        cell.bookInfo = info
        // set book image, name, and author
        cell.backgroundImageView?.image = UIImage(named: "gatsby")
        cell.customTitle.text = info.name
        cell.authorLabel.text = "by " + info.author
        // configure visible buttons
        // if checked-out, only show return
        // if reserved, only show pick-up (if date is before reserved date)
        // if picked-up and reserved, show check-out button
        if let book = checkIfInInventory(bookId: info.bookID) {
            // checked out
            if(book.isCheckedOut) {
                cell.checkedOutLabel.text = "Checked out, return on \(book.date)"
                cell.checkOutButton.setTitle("Return", for: UIControlState.normal)
                // should be hidden
                cell.reserveButton.isHidden = true
            }
            else if(book.isReserved) {
                // reserved but not picked up yet
                // hide right button and show pick-up
                cell.checkedOutLabel.text = "Reserved, pick up on \(book.date)"
                cell.checkOutButton.setTitle("Pick-Up", for: UIControlState.normal)
                cell.reserveButton.isHidden = true
            }
            // add if book is reserved and pickedUp (pickedUp is either when
            // date is past or book is manually picked-up)
        }
        else {
            // not checked out and both buttons should be visible
            cell.checkedOutLabel.text = "Not Checked Out"
        }

        cell.cellIsOpen(cellsIsOpen[index], animated: false)
    }

    // handle selection and
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DemoCollectionViewCell
            , currentIndex == indexPath.row else { return }

        if cell.isOpened == false {
            cell.cellIsOpen(true)
        } else {
            pushToViewController(getViewController())

            if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
                rightButton.animationSelected(true)
            }
        }
    }
}

// setup collection view
extension DemoViewController {

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DemoCollectionViewCell.self), for: indexPath)
    }
}
