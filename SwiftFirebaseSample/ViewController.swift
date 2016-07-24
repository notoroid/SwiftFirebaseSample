//
//  ViewController.swift
//  SwiftFirebaseSample
//
//  Created by 能登 要 on 2016/07/24.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var ownerTextField: UITextField!


    private var remoteRef: FIRDatabaseReference? = nil
    var remoteHandle: UInt = 0
    @IBOutlet weak var remoteTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateRemoteConnection()
    }

    override func viewDidAppear(animated: Bool) {

        remoteTextField.hidden = true

        // データを接続
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }

        appDelegate.textFieldRef?.observeEventType(.Value, withBlock: { (snapshot) -> Void in

            if let string = snapshot.value as? String {
              self.ownerTextField?.text = string
            }
        })

        super.viewDidAppear(animated)
    }

    @IBAction func onOwnerChange(sender: AnyObject) {
        print("onOwnerChange: call")
        
        if let textField = sender as? UITextField {
            guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
            
            let string = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            appDelegate.textFieldRef?.child(appDelegate.textFieldKeyName).setValue(string)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier: String = segue.identifier else {
            return
        }

        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else {
            return
        }

        switch identifier {
        case "QRCodeSegue":
            if let qrCodeViewController = segue.destinationViewController as? QRCodeViewController {
                qrCodeViewController.UUID = appDelegate.UUID
            }
        default:
            break
        }
    }

    @IBAction func unwindFromQRCode(segue: UIStoryboardSegue) {

    }

    @IBAction func unwindFromReader(segue: UIStoryboardSegue) {
        if let codeReaderViewController = segue.sourceViewController as? QRCodeReaderViewController {

            if remoteRef != nil {
                guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
               remoteRef?.child(appDelegate.textFieldKeyName).removeObserverWithHandle(remoteHandle)
            }

            remoteRef = codeReaderViewController.connectRef
            updateRemoteConnection()
        }
    }

    func updateRemoteConnection() {
        guard let remoteConnectRef = remoteRef else {
            ownerTextField.hidden = false
            remoteTextField.hidden = true
            return
        }

        ownerTextField.hidden = true
        remoteTextField.hidden = false

        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        remoteHandle = remoteConnectRef.child(appDelegate.textFieldKeyName).observeEventType(.Value, withBlock: { (snapshot) in
            if let string = snapshot.value as? String {
                self.remoteTextField?.text = string
            }
        })
    }

    @IBAction func onRemoteChange(sender: AnyObject)
    {
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        
        print("onRemoteChange: call")
        
        if let textField = sender as? UITextField {
            let string = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            remoteRef?.child(appDelegate.textFieldKeyName).setValue(string)
        }
    }

}

extension ViewController : UITextFieldDelegate {



}
