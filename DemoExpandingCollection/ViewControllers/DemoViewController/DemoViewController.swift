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
class DemoViewController: ExpandingViewController, AlertOnboardingDelegate{

    func alertOnboardingSkipped(_ currentStep: Int, maxStep: Int) {
        print("Onboarding skipped the \(currentStep) step and the max step he saw was the number \(maxStep)")
    }

    func alertOnboardingCompleted() {
        print("Onboarding completed!")
    }

    func alertOnboardingNext(_ nextStep: Int) {
        print("Next step triggered! \(nextStep)")
    }

    var alertView: AlertOnboarding!

    var arrayOfImage = ["tutorial1", "tutorial2", "tutorial3"]
    var arrayOfTitle = ["Browse Books", "Check out and Reserve", "Reminders"]
    var arrayOfDescription = ["Swipe left or right to browse the library's books",
                              "Swipe up at a book to checkout or reserve it",
                              "Get reminders on the day your book is due"]
    //sample library
    var library: [Book] = [Book(name: "The Great Gatsby", author: "Fitzgerald", checkedout: 0, reserved: 0, bookID: "240082", count: 10, imageURL: "bookCover/FhVmetipjl.png"),
                           Book(name: "Beloved", author: "Toni Morrison", checkedout: 0, reserved: 0, bookID: "123423", count: 10, imageURL: "bookCover/5hQ5vfHYli.png"),
                           Book(name: "Grapes of Wrath", author: "John steinbeck", checkedout: 0, reserved: 0, bookID: "145345", count: 10, imageURL: "bookCover/30GGO4fsWK.png"),
                           Book(name: "Hamlet", author: "William Shakespeare", checkedout: 0, reserved: 0, bookID: "204958", count: 10, imageURL: "bookCover/1x4VogV8X3.png"),
                           Book(name: "Harry Potter", author: "J. K. Rowling", checkedout: 0, reserved: 0, bookID: "580942", count: 10, imageURL: "bookCover/xLBEK6dHhx.png"),
                           Book(name: "Stargirl", author: "Jerry Spinelli", checkedout: 0, reserved: 0, bookID: "459283", count: 10, imageURL: "bookCover/tIVilwXj7j.png"),
                           Book(name: "The Hunger Games", author: "Suzanne Collins", checkedout: 0, reserved: 0, bookID: "598023", count: 10, imageURL: "bookCover/qjufd2RqyJ.png"),
                           Book(name: "The Kite Runner", author: "Khaled Hosseini", checkedout: 0, reserved: 0, bookID: "589432", count: 10, imageURL: "bookCover/90HlLz9UGr.png"),

                           ]
    //sample book covers
    var coverImages: [UIImage] = [UIImage(named:"Gatsby")!, UIImage(named:"Beloved")!,UIImage(named:"grapesofwrath")!,UIImage(named:"Hamlet")!,
                                  UIImage(named:"HarryPotter")!,UIImage(named:"stargirl")!,UIImage(named:"Thehungergames")!,UIImage(named:"TheKiteRunner")!]
    var ref: DatabaseReference!

    fileprivate var cellsIsOpen = [Bool]()
    fileprivate var items : [Book] = []
    
    //@IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var mapButton: AnimatingBarButton!

    @IBOutlet var pageLabel: UILabel!
    
    @IBOutlet weak var mapView: UIView!

    // search button clicked; handle events
    /*@IBAction func searchClicked(_ sender: Any) {
        print("here")
        
    }*/
    @IBAction func mapClicked(_ sender: Any) {
        //show map
        self.mapView.bringSubview(toFront: self.view)
        self.mapView.isHidden = false

    }
    @IBAction func extiClicked(_ sender: Any) {
        self.mapView.isHidden = true
    }
}

// lifecycle functinos; call networking functions and setup view
extension DemoViewController {


    override func viewDidLoad() {
        itemSize = CGSize(width: 256, height: 460)
        super.viewDidLoad()

        ref = Database.database().reference()

        self.mapView.isHidden = true

        alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        alertView.delegate = self

        //if first time open application
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            self.alertView.show()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }

        registerCell()
        addGesture(to: collectionView!)
        configureNavBar()
        loadBooks()
        loadUserInventory()
        fillCellIsOpenArray()

        //setup library
        //uploadImages()
        //setUpLibrary()
    }

    func scaleDownImage(image: UIImage) -> UIImage{
        var actualHeight: CGFloat = image.size.height
        var actualWidth: CGFloat = image.size.width
        let maxHeight: CGFloat = 700
        let maxWidth: CGFloat = 700
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        let compressionQuality: CGFloat = 0.5

        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }


        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality)
        UIGraphicsEndImageContext()

        //return [UIImage imageWithData:imageData]
        return UIImage(data: imageData!)!
    }

    func uploadImages(){
        for i in 0...self.coverImages.count-1 {
            LoadImage.uploadImage(name: library[i].name, image: self.scaleDownImage(image: self.coverImages[i]), completion: {downloadURL in
                
            })
        }
    }

    func setUpLibrary(){
        for book in self.library {
            self.ref.child("library").child(book.bookID).child("name").setValue(book.name) //setValue(["name": books[1].name])
            self.ref.child("library").child(book.bookID).child("author").setValue(book.author)//setValue(["author": books[1].author])
            self.ref.child("library").child(book.bookID).child("checkedout").setValue(book.checkedout)//setValue(["checkedout": String(books[1].checkedout)])
            self.ref.child("library").child(book.bookID).child("reserved").setValue(book.reserved)//setValue(["reserved": String(books[1].reserved)])
            self.ref.child("library").child(book.bookID).child("count").setValue(book.count)//setValue(["count": String(books[1].count)])
            self.ref.child("library").child(book.bookID).child("imageURL").setValue(book.imageURL)
        }
    }
}

// helper functions for collection view and networking
extension DemoViewController {

    fileprivate func registerCell() {
        let nib = UINib(nibName: String(describing: DemoCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: DemoCollectionViewCell.self))
        collectionView?.addSubview(mapView)
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
                let imageURL = dict["imageURL"] as! String
            
                
                var book = Book(name: name, author: author, checkedout: Int(checkedout), reserved: Int(reserved), bookID: key as! String, count: Int(count), imageURL: imageURL)
                // add book
                self.items.append(book)
                // handle UI
                self.fillCellIsOpenArray()
                // reload collection view
                self.collectionView?.reloadData()
            }
            self.loadImages()

            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func loadImages(){
        for book in self.items{
            LoadImage.downloadImage(imageurl: book.imageURL, completion: { data, url  in
                for index in 0..<self.items.count{
                    if (self.items[index].imageURL == url){
                        self.items[index].image = data
                        self.collectionView?.reloadData()
                    }
                }
            })
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
                    //let imageURL = dict["imageURL"] as! String
                    
                    // add book to User object
                    user.books.append(Book(bookID: bookid, isReserved: isReserved, isCheckedOut: isCheckedOut, date: date, imageURL: ""))
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
        cell.backgroundImageView?.image = info.image
        cell.customTitle.text = info.name
        cell.authorLabel.text = "by " + info.author

        print(user.books)
        // configure visible buttons
        // if checked-out, only show return
        // if reserved, only show pick-up (if date is before reserved date)
        // if picked-up and reserved, show check-out button
        if let book = checkIfInInventory(bookId: info.bookID) {
            // checked out
            if(book.isCheckedOut) {
                print("checkedout")
                print(book.checkedout)
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
            /*cell.reserveButton.isHidden = false
            cell.checkOutButton.isHidden = false
            cell.reserveButton.setTitle("Reserve", for: UIControlState.normal)
            cell.checkOutButton.setTitle("Check out", for: UIControlState.normal)*/

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
