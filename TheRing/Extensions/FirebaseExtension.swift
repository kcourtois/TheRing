//
//  FirebaseExtension.swift
//  TheRing
//
//  Created by Kévin Courtois on 02/07/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Foundation
import FirebaseAuth

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "MAIL_USED"
        case .userNotFound:
            return "ACCOUNT_NOT_FOUND"
        case .userDisabled:
            return "ACCOUNT_DISABLED"
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "WRONG_MAIL"
        case .networkError:
            return "NETWORK_ERROR"
        case .weakPassword:
            return "WEAK_PASSWORD"
        case .wrongPassword:
            return "WRONG_PASSWORD"
        default:
            return "ERROR_OCCURED"
        }
    }
}
