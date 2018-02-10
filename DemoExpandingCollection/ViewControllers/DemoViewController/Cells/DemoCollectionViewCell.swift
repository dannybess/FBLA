//
//  DemoCollectionViewCell.swift
//  TestCollectionView
//
//  Created by Alex K. on 12/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit
import AABlurAlertController

class DemoCollectionViewCell: BasePageCollectionCell {

    @IBOutlet weak var checkedOutLabel: UILabel!
    @IBOutlet weak var bookDetailsClick: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var customTitle: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
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
    
    @IBAction func checkOut(_ sender: Any) {
        /*let vc = AABlurAlertController()
        
        vc.addAction(action: AABlurAlertAction(title: "Cancel", style: AABlurActionStyle.modernCancel) { _ in
            print("cancel")
        })
        vc.addAction(action: AABlurAlertAction(title: "Check Out", style: AABlurActionStyle.modern) { _ in
            let vc2 = AABlurAlertController()
            vc2.alertTitle.text = "Success!"
            self.present(vc2, animated: true, completion: nil)
        })
        
        vc.alertStyle = AABlurAlertStyle.modern
        vc.topImageStyle = AABlurTopImageStyle.fullWidth
        vc.blurEffectStyle = .light
        vc.alertImage.image = UIImage(named: "truckmodal")
        vc.imageHeight = 110
        vc.alertImage.contentMode = .scaleAspectFill
        vc.alertImage.layer.masksToBounds = true
        vc.alertTitle.text = "Check Out \(self.customTitle.text!)"
        vc.alertSubtitle.text = "Are you sure you would like to check out the above book?"
        self.present(vc, animated: true, completion: nil)*/
    }
    
    @IBAction func reserveClicked(_ sender: Any) {
        print("RESERVE")
        print(self.customTitle.text!)
    }
    
    @IBAction func bookDetailsClicked(_ sender: Any) {
    }
    
}
