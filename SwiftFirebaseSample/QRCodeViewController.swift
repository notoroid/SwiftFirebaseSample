//
//  QRCodeViewController.swift
//  SwiftFirebaseSample
//
//  Created by 能登 要 on 2016/07/24.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

import UIKit
import CoreImage
import Firebase

class QRCodeViewController: UIViewController {

    private var initialized = false
    private var inviteRef: FIRDatabaseReference? = nil
    private var handle:UInt = 0

    @IBOutlet weak var QRCodeView: UIImageView!

    var UUID: String?

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        if initialized != true {
            initialized = true

            guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }

            guard let rootRef = appDelegate.rootRef else { return }

            let UUIDInvide = NSUUID().UUIDString
                // 招待用のUUID生成
            
            let dict = [appDelegate.UUIDKeyName:appDelegate.UUID]

            inviteRef = rootRef.child(appDelegate.inviteKeyName).child(UUIDInvide)
            
            var once:Bool = true;
            handle = inviteRef!.observeEventType(.Value, withBlock: { (snapshot) -> Void in
                print(snapshot.value)
                
                if once == true {
                    // 最初の初期値はスキップ
                    once = false
                }else{
                    self.performSegueWithIdentifier("returnToRootSegue", sender: nil)
                    self.inviteRef?.removeObserverWithHandle(self.handle)
                }
            } )
            
            // 値を格納
            inviteRef?.setValue(dict)

            // QUCOdeを作成

            let ciFilter = CIFilter(name: "CIQRCodeGenerator")
            ciFilter?.setDefaults()

            let data = UUIDInvide.dataUsingEncoding(NSUTF8StringEncoding)
            ciFilter?.setValue(data, forKey: "inputMessage")
            ciFilter?.setValue("L", forKey: "inputCorrectionLevel")

            // Core Imageコンテキストを取得したらCGImage→UIImageと変換して描画
            let ciContext = CIContext()
            let cgimg = ciContext.createCGImage((ciFilter?.outputImage)!, fromRect: (ciFilter?.outputImage?.extent)!)
            let image = UIImage(CGImage: cgimg, scale: 1.0, orientation: .Up)

            // 画面のUIImageViewに表示
            QRCodeView.layer.magnificationFilter = kCAFilterNearest
            QRCodeView.image = image
        }

        super.viewDidAppear(animated)
    }


}
