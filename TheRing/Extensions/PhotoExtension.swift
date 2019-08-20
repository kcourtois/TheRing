//
//  PhotoExtrension.swift
//  TheRing
//
//  Created by Kévin Courtois on 20/08/2019.
//  Copyright © 2019 Kévin Courtois. All rights reserved.
//

import Photos

// Extension for tournament share as photo
extension TournamentDetailController {
    //Check photo library permission
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            shareWithUrlAndText()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { result in
                if result == .authorized {
                    self.presentAlert(title: TRStrings.permissionGranted.localizedString,
                                      message: TRStrings.shareAuthorized.localizedString)
                } else {
                    self.presentPermissionDeniedAlert()
                }
            }
        case .restricted:
            presentPermissionDeniedAlert()
        case .denied:
            presentPermissionDeniedAlert()
        @unknown default:
            presentPermissionDeniedAlert()
        }
    }

    //Present view to user for image share
    private func shareWithUrlAndText() {
        guard let url = URL(string: "https://github.com/kcourtois/TheRing") else {
            presentAlert(title: TRStrings.error.localizedString, message: TRStrings.errorOccured.localizedString)
            return
        }
        let text = TRStrings.shareTournament.localizedString
        let image = getTournamentAsImage()

        let shareAll = [text, image, url] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    //Convert tournamentView to an image
    private func getTournamentAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: tournamentView.bounds.size)
        let image = renderer.image { _ in
            tournamentView.drawHierarchy(in: tournamentView.bounds, afterScreenUpdates: true)
        }
        return image
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
