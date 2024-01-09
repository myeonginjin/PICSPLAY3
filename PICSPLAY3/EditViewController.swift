//
//  EditViewController.swift
//  PICSPLAY3
//
//  Created by 진명인 on 12/29/23.
//

import UIKit

struct RGBAPixel {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8
}

class EditViewController: UIViewController {
    @IBOutlet var monochromeImgView: UIImageView!

    //imageToShow에는 편집된 사진 객체인 monochromeImgView가 prepare매소드를 통해 전달되어 있음
    var imageToShow: UIImage?
    
    var appliedGrayScaleImage: UIImage?
    
    //n회 이상 흑백 전환을 수행하기 위해 현재 이미지의 필터적용 여부 기록할 변수 지정
    var isOriginalImage = true
    
    var readyToShow = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //세그웨이를 통해 imageToShow에 정상적으로 데이터가 담겨져 있는지 확인하기 위해 옵셔널바인딩
        if let image = imageToShow {
            
            //옵셔널 변수인 imageToShow이 nill값을 가지고 있지 않음을 확인했음으로, 이를 서브화면 이미지 뷰어에 띄움
            monochromeImgView.image = image
        }
    }
    
    @IBAction func toggleFilter(_ sender: UIButton) {
        
        //이미지피커를 통해 사용자가 선택한 사진이 monochromeImgView 객체에 담겨있는지 확인
        guard let image = monochromeImgView.image else {
            
            //imgView객체에 이미지 데이터가 없을 경우 경고 모달창
            PicsplayAlert("No Image", message: "There is no image to apply the filter.")
            return
        }
        
        if isOriginalImage {
            // 현재 원본 이미지인 경우 흑백 필터 적용
            
            if let monochromeImage = applyMonochromeFilter(image: image) {
                monochromeImgView.image = monochromeImage
            }
        } else {
            // 현재 흑백 필터가 적용된 이미지인 경우 원본 이미지로 변경
            monochromeImgView.image = imageToShow
        }
        
        // 필터적용 여부 반전
        isOriginalImage.toggle()
    }
    // 픽셀 단위로 이미지 조작하는 함수
    func applyMonochromeFilter(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let pixelData = cgImage.dataProvider!.data    // 이미지에서를 Data 형태로 만듭니다.
        guard let data = CFDataGetBytePtr(pixelData) else {
            return nil  // 또는 다른 적절한 값으로 처리
        }  // 주소로 접근할 수 있도록 선언합니다.
        
        guard let grayScaleImage = getGrayScaleUIImage(pData: data, image: image) else {
            return nil
        }

        return grayScaleImage


    }



//    func getGrayScaleUIColor(pData: UnsafePointer<UInt8>, _ pixel: Int) -> UIColor {
//        let red = pData[pixel]
//        let green = pData[(pixel + 1)];
//        let blue = pData[pixel + 2];
//        let alpha = pData[pixel + 3];
//
////펴균값
//        return UIColor(red: CGFloat(red) * 0.2126 /255.0 , green: CGFloat(green) * 0.7152 /255.0, blue: CGFloat(blue) * 0.0722 /255.0, alpha: CGFloat(alpha)/255.0)
//    }



    func getGrayScaleUIImage(pData: UnsafePointer<UInt8> , image : UIImage) -> UIImage? {
        
        
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)

        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue

        // 픽셀 데이터로 사용할 메모리를 할당
        let rawdata = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: width * height)
        
        //메모리 누수 방지
//        defer {
//            rawdata.deallocate()
//        }
        
          
        
        for i in 0..<width * height {
            let gray = UInt8((Int(pData[i * bytesPerPixel]) + Int(pData[i * bytesPerPixel + 1]) + Int(pData[i * bytesPerPixel + 2])) / 3)
            rawdata[i] = RGBAPixel(red: gray, green: gray, blue: gray, alpha: pData[i * bytesPerPixel + 3])
            
        }

        // CGContext를 생성하고 픽셀 데이터를 이용하여 이미지를 그립니다.
        guard let context = CGContext(data: rawdata, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorspace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil) else {
            return nil
        }
                // CGImage를 생성합니다.
        guard let cgImage = context.makeImage() else {
            return nil
        }

        // CGImage를 UIImage로 변환하여 반환합니다.
        return UIImage(cgImage: cgImage)



    }

//
//    func renderImage(colors : [UIColor]) -> UIImage? {
//
//
//        return grayScaleUIImage
//    }

    //현재 뷰어에 띄워져 있는 사진 객체 기기 라이브러리에 저장
    @IBAction func saveToLibrary(_ sender: UIButton) {
        
        //뷰어에 이미지 객체 없다면 경고 모달 창
        guard let imageToSave = monochromeImgView.image else {
            PicsplayAlert("No Image", message: "There is no image to save.")
            return
        }

        //이미지 저장이 완료 된 후 호출될 콜백 메소드를(메소드 주소값을 통해) image로 지정
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        //error가 nill값이 아닌 경우 (사진을 저장하는 과정에서 에러 발생)
        if let error = error {
            //경고 모달창
            PicsplayAlert("Save Error", message: error.localizedDescription)
        } else {
            PicsplayAlert("Saved", message: "Image saved to Photo Library")
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
