//
//  EditViewController.swift
//  PICSPLAY3
//
//  Created by 진명인 on 12/29/23.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet var monochromeImage: UIImageView!

    //imageToShow에는 편집된 사진 객체인 monochromeImage가 prepare매서드를 통해 전달되어 있음
    var imageToShow: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = imageToShow {
            
            //전달받은 편집된 사진을 서브화면 이미지 뷰어에 띄움
            monochromeImage.image = image
        }
    }
}

