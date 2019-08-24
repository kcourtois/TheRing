//
//  ScannerController.swift
//  TheRing
//
//  Created by Kévin Courtois on 30/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import AVFoundation
import UIKit

//scanner controller handles qr code detection to add a friend
class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let userModel = UserListModel(userService: FirebaseUser())
    private var user: TRUser?

    override func viewDidLoad() {
        super.viewDidLoad()

        //check if user is logged in
        checkUserLogged()

        //SETUP OF THE VIEW AND CAPTURE
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        self.title = TRStrings.scanner.localizedString

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //runs capture if not running
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
        //set observers for notifications
        setObservers()
    }

    //set observers for notifications
    private func setObservers() {
        //Notification observer for didSendError
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendError),
                                               name: .didSendError, object: nil)
        //Notification observer for didSendUserInfo
        NotificationCenter.default.addObserver(self, selector: #selector(onDidSendUserInfo),
                                               name: .didSendUserInfo, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //stops capture when view disappear
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
        //remove observers on view disappear
        NotificationCenter.default.removeObserver(self, name: .didSendError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didSendUserInfo, object: nil)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //When code found, call found func, with the string captured as parameter
            found(code: stringValue)
        }
    }

    //prints an alert if capture fails
    private func failed() {
        presentAlert(title: TRStrings.scanNotSupported.localizedString,
                     message: TRStrings.deviceNoCamera.localizedString)
        captureSession = nil
    }

    //get user info with code given, and present an alert if code invalid
    private func found(code: String) {
        userModel.getUserInfo(uid: code)
    }

    //set user before segue to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailUserSegue",
            let userDetailVC = segue.destination as? UserDetailController {
            if let user = user {
                userDetailVC.user = user
            } else {
                return
            }
        }
    }

    //Triggers on notification didSendError
    @objc private func onDidSendError(_ notification: Notification) {
        self.presentAlertDelay(title: "Invalid code", message: "The code wasn't recognized.",
                               delay: 1, completion: {
                                self.captureSession.startRunning()
        })
    }

    //Triggers on notification didSendUserInfo
    @objc private func onDidSendUserInfo(_ notification: Notification) {
        if let data = notification.userInfo as? [String: TRUser] {
            for (_, user) in data {
                self.user = user
                performSegue(withIdentifier: "DetailUserSegue", sender: self)
            }
        }
    }
}
