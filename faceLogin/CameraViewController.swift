//
//  CameraViewController.swift
//  faceLogin
//
//  Created by Resembrink Correa on 6/27/20.
//  Copyright © 2020 Reloader. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import ProjectOxfordFace

enum PhotoType{
    case login
    case signup
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    @IBOutlet var cameraView: UIView!
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var photoType: PhotoType!
    
    var usersStorageRef: StorageReference!
    
    var personImage: UIImage!
    
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference(forURL: "gs://facelogin-d4b42.appspot.com")
        
        usersStorageRef = storageRef.child("users")
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDuoCamera,.builtInTelephotoCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        
        for device in (deviceSession.devices) {
            
            if device.position == AVCaptureDevice.Position.front {
                
                do {
                    
                    let input = try AVCaptureDeviceInput(device: device)
                    
                    if captureSession.canAddInput(input){
                        captureSession.addInput(input)
                        
                        if captureSession.canAddOutput(sessionOutput){
                            captureSession.addOutput(sessionOutput)
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                            previewLayer.connection!.videoOrientation = .portrait
                            
                            cameraView.layer.addSublayer(previewLayer)
                            cameraView.addSubview(button)
                            
                            previewLayer.position = CGPoint (x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                            previewLayer.bounds = cameraView.frame
                            
                            captureSession.startRunning()
                            
                        }
                    }
                    
                    
                } catch let avError {
                    print(avError)
                }
                
                
            }
            
        }
        
        
        
    }
    
    
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?){
        
        if let error = error{
            print(error.localizedDescription)
            return
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer){
            
            let userID = Auth.auth().currentUser?.uid
            let imageRef = usersStorageRef.child("\(userID!).jpg")
            
            if  photoType == PhotoType.signup{
                
                self.personImage = UIImage(data: dataImage)
                
                let client = MPOFaceServiceClient(subscriptionKey: "21210f44-79c0-4f92-b90e-bdb356c3cd31")!
                
                let data = personImage.jpegData(compressionQuality:  0.8)
                
                client.detect(with: data!, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock:  { (faces, error) in
                    
                    if error != nil {
                        print(error)
                    }
                    
                    if (faces!.count) > 1 || faces == nil {
                        print("too many not at all faces")
                        return
                    }
                    
                    
                    let uploadTask = imageRef.putData(dataImage, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                    })
                    uploadTask.resume()
                    
                })
                
                captureSession.stopRunning()
                previewLayer.removeFromSuperlayer()
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Logged")
                self.present(vc, animated: true, completion: nil)
                
                
            }
                
            else  if photoType == PhotoType.login{
                //verify the user
            }
            
        }
        
    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
        
        let  settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        sessionOutput.capturePhoto(with: settings, delegate: self)
    }
    
}
