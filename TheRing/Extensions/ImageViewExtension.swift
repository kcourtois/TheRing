//
//  ImageViewExtension.swift
//  TheRing
//
//  Created by Kévin Courtois on 06/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import UIKit

//Quick fix for a bug where tint color doesn't apply to the imageview
extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}
