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
    
    init(name: String, author: String, checkedout: Int, reserved: Int, bookID: String, count: Int){
        self.name = name
        self.author = author
        self.checkedout = checkedout
        self.reserved = reserved
        self.bookID = bookID
        self.count = count
    }
}
