//
//  PreviewContextView.swift
//  
//
//  Created by HonQi on 2021/5/29.
//

import SwiftUI


public struct PreviewContextView<Content: View>: UIViewRepresentable {
    let content: Content?
    let preferredContentSize: CGSize?
    let actions: [UIAction]
    let isPreviewOnly: Bool
    
    @Binding var isActive: Bool
    
    
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.addInteraction(UIContextMenuInteraction(delegate: context.coordinator))
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension PreviewContextView {
    public class Coordinator: NSObject, UIContextMenuInteractionDelegate {

        private let preview: PreviewContextView<Content>
        
        init(_ content: PreviewContextView<Content>) {
            self.preview = content
        }
        
        public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: {
                    let hostingController = UIHostingController(rootView: self.preview.content)
                    
                    if let preferredContentSize = self.preview.preferredContentSize {
                        hostingController.preferredContentSize = preferredContentSize
                    }
                    
                    return hostingController
                }, actionProvider: { _ in
                    UIMenu(title: "", children: self.preview.actions)
                }
            )
        }
        
        public func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionCommitAnimating
        ) {
            guard !preview.isPreviewOnly else { return }
            preview.isActive = true
        }
    }
}
