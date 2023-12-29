//
//  ViewController.swift
//  PICSPLAY3
//
//  Created by 진명인 on 12/28/23.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{ //델리게이트 프로토콜 추가
    
    //메인화면에 띄울 이미지 객체
    @IBOutlet var imgView: UIImageView!
    
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
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            
            //촬영 한 이미지 저장여부
            flagImageSave = true
            
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = ["public.image"]
            
            //편집 혀용 x
            imagePicker.allowsEditing = false
            
            //현재 뷰컨트롤러를 imagePicker로 대체
            present(imagePicker, animated: true, completion: nil)
        }
        
        //카메라 기능 실행 실패일 경우 경고 표시 메서드 실행
        else {
            PicsplayAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
    }
    //사진 불러오기 버튼 액션함수
    @IBAction func btnLoadImageFromLibrary(_ sender: UIButton) {
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            flagImageSave = false
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true, completion: nil)
        }
        
        else{
            PicsplayAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //미디어 종류를 확인하기 위해(프로토콜 준수성 확인) 이미지에 대한 정보룰 NSString 타입으로 강제 타입캐스팅
        let mediaType = info[UIImagePickerController.InfoKey.mediaType]
            as! NSString
        
        //미디어 종류가 이미지 형식이 맞는지 검사
        if mediaType.isEqual(to: "public.image" as String){
            
            //사진을 가져와 captureImage변수에 저장한 후 UIImage타입으로 조건부 타입캐스팅
            captureImage = info[UIImagePickerController.InfoKey.originalImage]
                            as? UIImage
            
            //기기 라이브러리에 이미지 저장
            if flagImageSave {
                UIImageWriteToSavedPhotosAlbum(captureImage, self, nil, nil)
            }
            
            //이미지 뷰어에 불러오거나 촬영한 이미지를 대입
            imgView.image = captureImage
        }
        
        //현재 뷰(이미지 피커) 제거
        self.dismiss(animated: true, completion: nil)
    }
    
    //사진촬영이나 선택을 중단할 경우 현재 이미지 피커 뷰를 제거하는 로직
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func getMonochromeImage(_ sender: UIButton) {
        
        //이미지피커를 통해 사용자가 선택한 사진이 imgView객체에 담겨있는지 확인
        guard let image = imgView.image else {
            
            //imgView객체에 이미지 데이터가 없을 경우 경고 모달창
            PicsplayAlert("No Image", message: "There is no image to apply the filter.")
            return
        }

        //Core Image의 프로세싱을 수행할 CIContext 생성
        let context = CIContext(options: nil)
        
        //immutable한 UIImage 객체를 편집하기 위해 CIImage 형식으로 변환
        guard let ciImage = CIImage(image: image) else { return }

        //흑백필터를 적용하는 CIFilter 객체 CIPhotoEffectMono를 filter에 지정
        if let filter = CIFilter(name: "CIPhotoEffectMono") {
            
            //키값 kCIInputImageKey를 통해 ciImage를 입력이미지로 지정
            filter.setValue(ciImage, forKey: kCIInputImageKey)

            //프로세싱이 완료된 출력이미지를 outputCIImage에 지정
            if let outputCIImage = filter.outputImage,
               
                //뷰어를 통해 나타내거나 파일에 저장할 수 있는 코어 그래픽 이미지 형식으로 렌더링
               let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                
                //UIKit에서 사용할 수 있는 형식인 UIImage로 변환
                let monochromeImage = UIImage(cgImage: cgImage)
                
                
                //showEditViewSegue식별자를 가진 Segue를 트리거함과 동시에 monochromeImage객체를 전달하라고 명령
                performSegue(withIdentifier: "showEditViewSegue", sender: monochromeImage)
            }
        }
    }

    //Segue가 작동되기 전 호출되는 함수
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditViewSegue" {
            
            //세그웨이의 목적지를 EditViewController로 옵셔널 타입으로 캐스팅한 후 destinationVC에 할당
            if let destinationVC = segue.destination as? EditViewController {
                
                //performSegue를 통해 sender에 담겨있던 monochromeImage객체를 UIImage로 옵셔널 타입 캐스팅 후 monochromeImage에 할당
                if let monochromeImage = sender as? UIImage {
                    
                    //destinationVC에 할당되어 있는 EditViewController의 imageToShow 변수에 monochromeImage 객체를 할당
                    destinationVC.imageToShow = monochromeImage
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

