//
//  QRCodeReaderViewController.swift
//  SwiftFirebaseSample
//
//  Created by 能登 要 on 2016/07/24.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class QRCodeReaderViewController: UIViewController {
    private var previewLayer: AVCaptureVideoPreviewLayer? = nil
    private var isUsingFrontFacingCamera: Bool = false
    var connectRef: FIRDatabaseReference? = nil

    @IBOutlet weak var previewView: UIView!

    override func viewDidAppear(animated: Bool) {

        setupAVCapture()

        super.viewDidAppear(animated)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }

    func setupAVCapture() -> Void {

        let session = AVCaptureSession()

        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            session .canSetSessionPreset(AVCaptureSessionPreset640x480)
        } else {
            session .canSetSessionPreset(AVCaptureSessionPresetPhoto)
        }

        let device: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)

        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)

            isUsingFrontFacingCamera = false
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }

            let metaOutput = AVCaptureMetadataOutput()

            metaOutput.setMetadataObjectsDelegate(self, queue:dispatch_queue_create("myQueue.metadata", DISPATCH_QUEUE_SERIAL) )

            // アウトプットに追加
            if session.canAddOutput(metaOutput) {
                session.addOutput(metaOutput)
            }

            metaOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]

            if let previewLayer = AVCaptureVideoPreviewLayer(session: session) {
                previewLayer.backgroundColor = UIColor.blueColor().CGColor
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill


                let rootLayer = previewView.layer
                rootLayer.masksToBounds = true

                previewLayer.frame = rootLayer.bounds
                rootLayer.addSublayer(previewLayer)
                session.startRunning()
            }
        } catch let e {
            let error = e as NSError

            let alertController = UIAlertController(title: "Failed with error \(error.code)", message: error.localizedDescription, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: { _ in

            }) )

            self.presentViewController(alertController, animated: true, completion: {
                self .performSegueWithIdentifier("returnToRootSegue2", sender: nil)
            })

            teardownAVCapture()
        }
    }

    func teardownAVCapture() -> Void {
        previewLayer?.removeFromSuperlayer()
    }
}

extension QRCodeReaderViewController : AVCaptureMetadataOutputObjectsDelegate {

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }

        for data in metadataObjects {
            if let metadataMachineReadableCodeObject = data as?AVMetadataMachineReadableCodeObject {

                if let inviteUUID = metadataMachineReadableCodeObject.stringValue {

                    let inviteRef = appDelegate.rootRef?.child(appDelegate.inviteKeyName).child(inviteUUID)

                    inviteRef?.observeEventType(.Value, withBlock: { (snapshot) in
                        if let dict = snapshot.value as? Dictionary<String, AnyObject> {

                            if let UUID = dict[appDelegate.UUIDKeyName] as? String {

                                self.connectRef = appDelegate.rootRef?.child(appDelegate.deviceKeyName).child(UUID)
                                    // 接続先を確保

                                self .performSegueWithIdentifier("returnToRootSegue2", sender: nil)


                                // 招待Refを削除(削除も通知される)
                                inviteRef?.removeValueWithCompletionBlock({ _ in

                                })
                            }
                        }
                    })
                }
            }
        }

    }

}
