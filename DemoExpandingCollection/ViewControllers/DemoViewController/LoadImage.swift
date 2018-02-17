//
//  Image.swift
//  FBLA2018
//
//  Created by Patrick Li on 2/13/18.
//  Copyright © 2018 Dali Labs, Inc. All rights reserved.
//

import Foundation
import Firebase
import UIKit

//image storage variables
let storage = Storage.storage()
let storageRef = storage.reference(forURL: "gs://flba2018-8b768.appspot.com/")

class LoadImage {

    class func randomStringWithLength (len : Int) -> NSString {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        let randomString : NSMutableString = NSMutableString(capacity: len)

        for i in 0..<len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }

        return randomString
    }

    class func uploadImage(image : UIImage, completion : @escaping (_ downloadURL : NSURL) -> Void) {
        let imageData : NSData = UIImagePNGRepresentation(image)! as NSData
        let testRef = storageRef.child("bookCover/\(randomStringWithLength(len: 10)).png")

        let uploadTask = testRef.putData(imageData as Data, metadata: nil) { metadata, error in
            if (error != nil) {
                print(error.debugDescription)
            } else {
                let downloadURL = metadata!.downloadURL()
                completion(downloadURL! as NSURL)
            }
        }
    }

    class func downloadImage(imageurl: String, completion: @escaping (_ image: UIImage, _ imageURL: String) -> Void) {
        let ref = storageRef.child(imageurl)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let myImage = UIImage(data: data!)
                completion(myImage!, imageurl)
            }
        }

    }


}

