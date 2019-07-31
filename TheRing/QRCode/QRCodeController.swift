//
//  QRCodeController.swift
//  TheRing
//
//  Created by Kévin Courtois on 30/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

class QRCodeController: UIViewController {
    @IBOutlet weak var QRImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        QRImageView.image = generateQRCode(from: Preferences().user.uid)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.view.addGestureRecognizer(tap)
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
