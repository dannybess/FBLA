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
import DatePickerDialog

class DemoCollectionViewCell: BasePageCollectionCell {

    @IBOutlet weak var checkedOutLabel: UILabel!
    @IBOutlet weak var bookDetailsClick: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var customTitle: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    // create book object that can be passed through VC
    var bookInfo : Book = Book(name: "", author: "", checkedout: 0, reserved: 0, bookID: "", count: 0, imageURL: "")
    
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
    
    // return date for checkout
    // by default, is 31 days after current date
    func dateFormatterCheckOut() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        let currDate = Date()
        let newDate = Calendar.current.date(byAdding: .month, value:  1, to: currDate)
        return formatter.string(from: newDate!)
    }
    
    // return date for when book is overdue
    func dateFormatterOverdue() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        let currDate = Date()
        let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currDate)
        let addedDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate!)
        return formatter.string(from: addedDate!)
    }
    
    // return date from string
    func stringToDate(date : String) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        return formatter.date(from: date)!
    }
    
    // left button clicked
    // take according action (check out, return, reserve, pickup)
    @IBAction func checkOut(_ sender: Any) {
        // check current state of button
        switch self.checkOutButton.titleLabel?.text! {
        // normal state, check-out book
        case "Check Out"?:
            // check if copies of book left
            if(bookInfo.count < 1) {
                let root = UIApplication.shared.keyWindow?.rootViewController
                let alertController = UIAlertController(title: "Error", message:
                    "Sorry! There are no copies of this book left!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                root!.present(alertController, animated: true, completion: nil)
            }
            else {
                checkOutHelper()
            }
        // book needs to be returned
        case "Return"?:
            returnCheckedout(user: user, returnBookID: bookInfo.bookID)
        case "Pick-Up"?:
            pickUp(user: user, bookId: bookInfo.bookID)
        default:
            return
        }
    }
    
    func checkOutHelper() {
        // get access to root VC
        let root = UIApplication.shared.keyWindow?.rootViewController
        user.books.append(bookInfo)
        var ref = Database.database().reference()
        let schoolID = user.schoolID
        
        //adding book to user book list
        ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("name").setValue(bookInfo.name)//setValue(["name":bookInfo.name])
        ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("author").setValue(bookInfo.author)//setValue(["author":bookInfo.author])
        ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("checkedout").setValue(true)//setValue(["checkedout":"true"])
        ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("reserved").setValue(false)//setValue(["reserved":"false"])
        ref.child("users").child(schoolID).child("books").child(bookInfo.bookID).child("date").setValue(dateFormatterCheckOut())//setValue(["reserved":"false"])

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
            let alertController = UIAlertController(title: "Success!", message:
                "You have now checked out this book!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.checkOutButton.setTitle("Return", for: UIControlState.normal)
            let date = self.dateFormatterCheckOut()
            self.checkedOutLabel.text = "Checked out, return on \(date)"
            self.reserveButton.isHidden = true
            root!.present(alertController, animated: true, completion: nil)
            
            // set local notif

            let convertedCheckOutDate = self.stringToDate(date: date)
            print(self.dateFormatterOverdue())
            let convertedOverdueDate = self.stringToDate(date: self.dateFormatterOverdue())
            Reminder.setReminder(type: "today", date: convertedCheckOutDate, book: self.bookInfo)
            Reminder.setReminder(type: "overdue", date: convertedOverdueDate, book: self.bookInfo)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    //returns the book to the library, and removes the book from user's list of checkouted books
    func returnCheckedout(user: User, returnBookID: String){
        var ref = Database.database().reference()
        let root = UIApplication.shared.keyWindow?.rootViewController

        //remove book locally

        for index in 0...user.books.count-1{
            if user.books[index].bookID == returnBookID {
                user.books.remove(at: index)

            }
        }
        print("userbooks")
        print(user.books)

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
            self.reserveButton.isHidden = false
            let alertController = UIAlertController(title: "Success!", message:
                    "You have now returned this book!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            root!.present(alertController, animated: true, completion: nil)
                
            // remove local notifications
            Reminder.removeReminder(type: "today", book: self.bookInfo)
            Reminder.removeReminder(type: "overdue", book: self.bookInfo)
                
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func reserveClicked(_ sender: Any) {
        // get date from user
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            // user selected date
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let date = (formatter.string(from: dt))
                self.reserve(user: user, reservedBook: self.bookInfo, date: date)
            }
        }
    }
    
    // helper function for reserveClicked() to avoid
    // too much nested code
    func reserve(user: User, reservedBook: Book, date : String) {
        var ref = Database.database().reference()
        user.books.append(reservedBook)
        
        let schoolID = user.schoolID

        //adding book to user book list
        ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("name").setValue(reservedBook.name)//setValue(["name":checkedoutBook.name])
        ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("author").setValue(reservedBook.author)//setValue(["author":checkedoutBook.author])
        ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("checkedout").setValue(false)//setValue(["checkedout":"true"])
        ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("reserved").setValue(true)//setValue(["reserved":"false"])
        ref.child("users").child(schoolID).child("books").child(reservedBook.bookID).child("date").setValue(date)//setValue(["reserved":"false"])

        
        //retreving library info
        ref.child("library").child(String(reservedBook.bookID)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            var reserved = 0
            if let val = value?["reserved"] as? Int {
                reserved = val + 1
            }
            else{
                print("error not integer")
            }
            
            var count = 0
            if let val = value?["count"] as? Int {
                count = val - 1
            }
            else{
                print("error not integer")
            }
            
            //updating the library book count
            ref.child("library").child(String(reservedBook.bookID)).child("reserved").setValue(reserved)
            ref.child("library").child(String(reservedBook.bookID)).child("count").setValue(count)
            self.reserveButton.isHidden = true
            self.checkOutButton.setTitle("Pick-Up", for: UIControlState.normal)
            self.checkedOutLabel.text = "Reserved, pick up on \(date)"
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func pickUp(user: User, bookId: String) {
        var ref = Database.database().reference()
        let root = UIApplication.shared.keyWindow?.rootViewController
       // update values
        ref.child("users").child(user.schoolID).child("books").child(bookId).child("reserved").setValue(false)
        ref.child("users").child(user.schoolID).child("books").child(bookId).child("checkedout").setValue(true)
        ref.child("users").child(user.schoolID).child("books").child(bookId).child("date").setValue(dateFormatterCheckOut())
        ref.child("library").child(bookId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            var checkedout = 0
            if let val = value?["checkedout"] as? Int {
                checkedout = (val + 1)
            }
            else{
                print("error not integer")
            }
            
            var reserved = 0
            if let val = value?["reserved"] as? Int {
                reserved = (val - 1)
            }
            else{
                print("error not integer")
            }
            
            //updating the library book count
            ref.child("library").child(String(self.bookInfo.bookID)).child("checkedout").setValue(checkedout) //setValue(["checkedout": checkedout])
            ref.child("library").child(String(self.bookInfo.bookID)).child("reserved").setValue(reserved) //setValue(["count": count])
            let alertController = UIAlertController(title: "Success!", message:
                "You have now picked-up this book!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.checkOutButton.setTitle("Return", for: UIControlState.normal)
            let date = self.dateFormatterCheckOut()
            self.checkedOutLabel.text = "Checked out, return on \(date)"
            self.reserveButton.isHidden = true
            root!.present(alertController, animated: true, completion: nil)
            
            // set local notif
            let convertedCheckOutDate = self.stringToDate(date: date)
            let convertedOverdueDate = self.stringToDate(date: self.dateFormatterOverdue())
            Reminder.setReminder(type: "today", date: convertedCheckOutDate, book: self.bookInfo)
            Reminder.setReminder(type: "overdue", date: convertedOverdueDate, book: self.bookInfo)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func bookDetailsClicked(_ sender: Any) {
    }
    
}
