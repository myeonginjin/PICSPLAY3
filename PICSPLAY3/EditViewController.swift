//
//  EditViewController.swift
//  PICSPLAY3
//
//  Created by 진명인 on 12/29/23.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet var monochromeImage: UIImageView!

    var imageToShow: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = imageToShow {
            monochromeImage.image = image
        }
    }
}

