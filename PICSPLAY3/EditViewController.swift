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

        //세그웨이를 통해 imageToShow에 정상적으로 데이터가 담겨져 있는지 확인하기 위해 옵셔널바인딩
        if let image = imageToShow {
            
            //옵셔널 변수인 imageToShow이 nill값을 가지고 있지 않음을 확인했음으로, 이를 서브화면 이미지 뷰어에 띄움
            monochromeImage.image = image
        }
    }
}

