//
//  QRCodeController.swift
//  TheRing
//
//  Created by Kévin Courtois on 30/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeController: UIViewController {
    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var scanButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        //generate qr code from uid
        QRImageView.image = generateQRCode(from: Preferences().user.uid)
        scanButton.setTitle(TRStrings.scanCode.localizedString, for: .normal)
        self.title = TRStrings.addFriends.localizedString
    }

    //func to generate qr code
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            //scale factor to have an imageview with no blur
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    //scan code
    @IBAction func scanCodeTapped(_ sender: Any) {
        proceedWithCameraAccess(identifier: "scannerSegue")
    }
}

// MARK: - Camera permission
extension QRCodeController {
    //ask permission for camera if not done, and perform segue
    func proceedWithCameraAccess(identifier: String) {
        AVCaptureDevice.requestAccess(for: .video) { success in
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: identifier, sender: nil)
                }
            } else {
                self.presentPermissionDeniedAlert()
            }
        }
    }

    //Shows a popup to access settings if user denied photolibrary permission
    private func presentPermissionDeniedAlert() {
        //Initialisation of the alert
        let alertController = UIAlertController(title: TRStrings.permissionDenied.localizedString,
                                                message: TRStrings.goToSettings.localizedString,
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: TRStrings.settings.localizedString, style: .default) { (_) -> Void in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (_) in })
                }
            }
        }
        let cancelAction = UIAlertAction(title: TRStrings.cancel.localizedString, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        //Shows alert
        present(alertController, animated: true, completion: nil)
    }
}
