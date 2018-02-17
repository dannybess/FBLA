//
//  Misc.swift
//  DemoExpandingCollection
//
//  Created by Daniel Bessonov on 2/9/18.
//  Copyright © 2018 Alex K. All rights reserved.
//

import Foundation
import UIKit

class User {
    var schoolID: String = ""
    var name: String = ""
    var books: [Book] = []
    
    init(schoolID: String, name: String, books: [Book]){
        self.schoolID = schoolID
        self.name = name
        self.books = books
    }
}

class Book {
    var name: String = ""
    var author: String = ""
    var checkedout: Int = 0
    var reserved: Int = 0
    var bookID: String = ""
    var count: Int = 0
    var isReserved : Bool = false
    var date : String = ""
    var isCheckedOut : Bool = false
    var imageURL: String = ""
    var image: UIImage = UIImage(named: "dots")!
    
    // normal init
    init(name: String, author: String, checkedout: Int, reserved: Int, bookID: String, count: Int, imageURL: String){
        self.name = name
        self.author = author
        self.checkedout = checkedout
        self.reserved = reserved
        self.bookID = bookID
        self.count = count
        self.imageURL = imageURL
    }
    
    // init for storing books for user inventory
    init(bookID: String, isReserved : Bool, isCheckedOut : Bool, date : String, imageURL: String) {
        self.bookID = bookID
        self.name = ""
        self.author = ""
        self.checkedout = 0
        self.reserved = 0
        self.count = 0
        self.isReserved = isReserved
        self.date = date
        self.isCheckedOut = isCheckedOut
        self.imageURL = imageURL
    }
}


