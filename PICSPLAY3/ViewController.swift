//
//  ViewController.swift
//  PICSPLAY3
//
//  Created by 진명인 on 12/28/23.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{ //델리게이트 프로토콜 추가
    
    
    //UIImagePickerController의 인스턴스 변수
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    //촬영하거나 라이브러리로부터 불러올 이미지 객체
    var captureImage: UIImage!
    
    //이미지 저장 여부 나타낼 변수
    var flagImageSave = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //촬영하기 버튼 액션함수
    @IBAction func btnCaptureImageFromCamera(_ sender: UIButton) {
        
        //현재 디바이스의 카메라를 사용할 수 있는지 여부 확인
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            
            //유저가 편집을 위해 사진을 촬영했을 경우 해당 사진 라이브러리에 저장
            flagImageSave = true
            
            //현재 뷰컨트롤러를 이미지 피커 객체의 대리자로 위임 (이후 뷰컨트롤러가 이미지피커와 관련된 이벤트 처리 가능)
            imagePicker.delegate = self
            
            //이미지 피커의 데이터 소스로 사용할 소스 타입 결정
            imagePicker.sourceType = .camera
            
            //이미지 피커가 허용할 미디어 타입 지정
            imagePicker.mediaTypes = ["public.image"]
            
            //편집 혀용 x
            imagePicker.allowsEditing = false
            
            //유저에게 촬영 및 사진 선택하는 인터페이스 제공
            present(imagePicker, animated: true, completion: nil)
        }
        
        //카메라 기능 실행 실패일 경우 경고 표시 메서드 실행
        else {
            PicsplayAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
    }
    

    //사진 불러오기 버튼 액션함수
    @IBAction func btnLoadImageFromLibrary(_ sender: UIButton) {
        
        //현재 디바이스의 라이브러리를 사용할 수 있는지 여부 확인
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            flagImageSave = false
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
        
        else{
            PicsplayAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
        }
    }
    
    //UIImagePickerController에 의해 present매소드 종료 후 호출
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //미디어 종류를 확인하기 위해(프로토콜 준수성 확인) 이미지에 대한 정보룰 NSString 타입으로 강제 타입캐스팅 (NSString 아닐 시 런타임 에러)
        let mediaType = info[UIImagePickerController.InfoKey.mediaType]
            as! NSString
        
        //미디어 종류가 이미지 형식이 맞는지 검사
        if mediaType.isEqual(to: "public.image" as String){
            
            //사진을 가져와 captureImage변수에 저장한 후 UIImage타입으로 옵셔널 타입캐스팅 ( 캐스팅 실패 시 런타임 에러가 아닌 nill값 반환)
            captureImage = info[UIImagePickerController.InfoKey.originalImage]
                            as? UIImage
            
            // 사진 촬영 후 사진 객체가 회전되어 저장되는 에러 해결
            let fixedImage = fixOrientation(img: captureImage)
            
            //기기 라이브러리에 이미지 저장 (사진 촬영하기 기능 사용 시에만)
            if flagImageSave {
                UIImageWriteToSavedPhotosAlbum(fixedImage, self, nil, nil)
            }
            
            //showEditViewSegue 식별자를 가진 세그웨이를 트리거함과 동시에, fixedImage 객체를 전환될 뷰컨트롤러에 전달 (prepare 매소드 호출)
            performSegue(withIdentifier: "showEditViewSegue", sender: fixedImage)
        }
        
        //현재 이미지 피커 해제
        self.dismiss(animated: true, completion: nil)
    }
    
    //사진촬영이나 선택을 중단할 경우 현재 이미지 피커 뷰를 제거하는 로직
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //이미지 회전 문제 해결 함수
    func fixOrientation(img: UIImage) -> UIImage {
        if img.imageOrientation == .up {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
    



    //Segue가 작동되기 전 호출되는 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditViewSegue" {
            
            //세그웨이의 목적지를 EditViewController로 옵셔널 타입으로 캐스팅한 후 destinationVC에 할당
            if let destinationVC = segue.destination as? EditViewController {
                
                //performSegue를 통해 sender에 담겨있던 monochromeImage객체를 UIImage로 옵셔널 타입 캐스팅 후 monochromeImage에 할당
                if let image = sender as? UIImage {
                    
                    //destinationVC에 할당되어 있는 EditViewController의 imageToShow 변수에 monochromeImage 객체를 할당
                    destinationVC.imageToShow = image
                }
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

