import SwiftUI
import UIKit

struct ShareService {
    static func shareDrill(_ drill: Drill) {
        guard let jsonString = drill.toJSONString() else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [jsonString],
            applicationActivities: nil
        )
        
        // Find the top-most view controller to present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // For iPad compatibility
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = rootVC.view
                popoverController.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
