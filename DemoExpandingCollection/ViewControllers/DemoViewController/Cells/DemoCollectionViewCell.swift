//
//  DemoCollectionViewCell.swift
//  TestCollectionView
//
//  Created by Alex K. on 12/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit
import AABlurAlertController
import Firebase

class DemoCollectionViewCell: BasePageCollectionCell {

    @IBOutlet weak var checkedOutLabel: UILabel!
    @IBOutlet weak var bookDetailsClick: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var customTitle: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    var bookInfo : Book = Book(name: "", author: "", checkedout: 0, reserved: 0, bookID: "", count: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkOutButton.layer.cornerRadius = 5.0
        self.reserveButton.layer.cornerRadius = 5.0
        if(self.isOpened) {
            self.addSubview(checkOutButton)
            self.addSubview(reserveButton)
        }
        customTitle.layer.shadowRadius = 2
        customTitle.layer.shadowOffset = CGSize(width: 0, height: 3)
        customTitle.layer.shadowOpacity = 0.2
    }
    
    // check if user alerady has book
    func checkIfInInventory(bookId : String) -> Bool {
        for book in user.books {
            if(book.bookID == bookId) {
                return true
            }
        }
        return false
    }
    
    @IBAction func checkOut(_ sender: Any) {
        // get access to root VC
        let root = UIApplication.shared.keyWindow?.rootViewController
        
        // check if user already has checked out book
        if(checkIfInInventory(bookId: bookInfo.bookID) || self.checkOutButton.titleLabel?.text == "Return") {
            returnCheckedout(user: user, returnBookID: bookInfo.bookID)
        }
        // check if there are sufficient copies of the book left
        else if(bookInfo.count < 1) {
            let alertController = UIAlertController(title: "Error", message:
                "Sorry! There are no copies of this book left!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            root!.present(alertController, animated: true, completion: nil)
        }
        else {
            user.books.append(bookInfo)
            self.checkedOutLabel.text = "Checked Out"
            var ref = Database.database().reference()
            let schoolID = user.schoolID
            
            //adding book to user book list
            ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("name").setValue(bookInfo.name)//setValue(["name":bookInfo.name])
            ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("author").setValue(bookInfo.author)//setValue(["author":bookInfo.author])
            ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("checkedout").setValue(true)//setValue(["checkedout":"true"])
            ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("reserved").setValue(false)//setValue(["reserved":"false"])
            
            //retreving library info
            ref.child("library").child(String(bookInfo.bookID)).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                
                var checkedout = 0
                if let val = value?["checkedout"] as? Int {
                    checkedout = (val + 1)
                }
                else{
                    print("error not integer")
                }
                
                var count = 0
                if let val = value?["count"] as? Int {
                    count = (val - 1)
                }
                else{
                    print("error not integer")
                }
                
                //updating the library book count
                ref.child("library").child(String(self.bookInfo.bookID)).child("checkedout").setValue(checkedout) //setValue(["checkedout": checkedout])
                ref.child("library").child(String(self.bookInfo.bookID)).child("count").setValue(count) //setValue(["count": count])
                self.checkOutButton.setTitle("Return", for: UIControlState.normal)
                let alertController = UIAlertController(title: "Success!", message:
                    "You have now checked out this book!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                root!.present(alertController, animated: true, completion: nil)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    //returns the book to the library, and removes the book from user's list of checkouted books
    func returnCheckedout(user: User, returnBookID: String){
        var ref = Database.database().reference()
        let root = UIApplication.shared.keyWindow?.rootViewController
        //remove book locally
        
        for index in 0..<user.books.count-1{
            if user.books[index].bookID == returnBookID {
                user.books.remove(at: index)
                }
            }
        
            ref.child("users").child(user.schoolID).child("books").child(returnBookID).removeValue()
            ref.child("library").child(returnBookID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            
            var checkedout = 0
            if let val = value?["checkedout"] as? Int {
                print(val)
                print("here")
                checkedout = val - 1
            }
            else{
                print("error not integer")
            }
            
            var count = 0
            if let val = value?["count"] as? Int {
                count = val + 1
            }
            else{
                print("error not integer")
            }
            
            //updating the library book count
            ref.child("library").child(returnBookID).child("checkedout").setValue(checkedout)
            ref.child("library").child(returnBookID).child("count").setValue(count)
            self.checkedOutLabel.text = "Not Checked Out"
            self.checkOutButton.setTitle("Check Out", for: UIControlState.normal)
            let alertController = UIAlertController(title: "Success!", message:
                    "You have now returned this book!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
            root!.present(alertController, animated: true, completion: nil)
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func reserveClicked(_ sender: Any) {
        print("RESERVE")
        print(self.customTitle.text!)
    }
    
    @IBAction func bookDetailsClicked(_ sender: Any) {
    }
    
}
