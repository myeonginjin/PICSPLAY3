//
//  EditViewController.swift
//  PICSPLAY3
//
//  Created by 진명인 on 12/29/23.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet var monochromeImgView: UIImageView!

    //imageToShow에는 편집된 사진 객체인 monochromeImgView가 prepare매서드를 통해 전달되어 있음
    var imageToShow: UIImage?
    var isOriginalImage = true

    override func viewDidLoad() {
        super.viewDidLoad()

        //세그웨이를 통해 imageToShow에 정상적으로 데이터가 담겨져 있는지 확인하기 위해 옵셔널바인딩
        if let image = imageToShow {
            
            //옵셔널 변수인 imageToShow이 nill값을 가지고 있지 않음을 확인했음으로, 이를 서브화면 이미지 뷰어에 띄움
            monochromeImgView.image = image
        }
    }
    
    @IBAction func toggleFilter(_ sender: UIButton) {
        
        //이미지피커를 통해 사용자가 선택한 사진이 imgView객체에 담겨있는지 확인
        guard let image = monochromeImgView.image else {
            
            //imgView객체에 이미지 데이터가 없을 경우 경고 모달창
            PicsplayAlert("No Image", message: "There is no image to apply the filter.")
            return
        }
        
        if isOriginalImage {
            // 현재 원본 이미지인 경우 흑백 필터 적용
            applyMonochromeFilter(to: image)
        } else {
            // 현재 흑백 필터가 적용된 이미지인 경우 원본 이미지로 변경
            monochromeImgView.image = imageToShow
        }
        
        // 상태 토글
        isOriginalImage.toggle()
    }
        
        
    func applyMonochromeFilter(to image: UIImage) {
        //Core Image 프레임워크의 프로세싱(이미지 처리 결과 렌더링 및 이미지 분석)을 수행할 CIContext 생성
        let context = CIContext(options: nil)
        
        //immutable한 UIImage 객체를 편집하기 위해 CIImage 형식으로 변환
        guard let ciImage = CIImage(image: image) else { return }

        //흑백필터를 적용하는 CIFilter 객체 CIPhotoEffectMono를 filter에 지정
        if let filter = CIFilter(name: "CIPhotoEffectMono") {

            //키값 kCIInputImageKey를 통해 ciImage를 입력이미지로 지정
            filter.setValue(ciImage, forKey: kCIInputImageKey)

            //프로세싱이 완료된 출력이미지를 outputCIImage에 지정
            if let outputCIImage = filter.outputImage,
               
                //뷰어를 통해 나타내거나 파일에 저장할 수 있는 UIImage로 변환하기 위해 우선 cgImage 형식으로 렌더링
               let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                
                //UIKit에서 사용할 수 있는 형식인 UIImage로 변환
                monochromeImgView.image = UIImage(cgImage: cgImage)
            

            }
        }
    }
    
    //경고 모달창 매서드
    func PicsplayAlert(_ title : String, message: String){
        let alert = UIAlertController(title : title, message: message,
                                      preferredStyle:  UIAlertController.Style.alert   )
        let action = UIAlertAction(title : "OK", style: UIAlertAction.Style.default,
                                   handler: nil )
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

