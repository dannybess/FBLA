//
//  Networking.swift
//  DemoExpandingCollection
//
//  Created by Daniel Bessonov on 2/10/18.
//  Copyright © 2018 Alex K. All rights reserved.
//

import Foundation
import Firebase

class Networking {
    var ref: DatabaseReference!
    func readLibrary() {
        var loadedBooks : [Book] = []
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
                
                var book = Book(name: name, author: author, checkedout: checkedout, reserved: reserved, bookID: key as! String, count: count, imageURL: imageURL)
                loadedBooks.append(book)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
}
