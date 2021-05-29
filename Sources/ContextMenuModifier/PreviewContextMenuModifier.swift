//
//  PreviewContextView.swift
//
//
//  Created by HonQi on 2021/5/29.
//

import SwiftUI


extension View {
    @ViewBuilder fileprivate func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    public func previewContextMenu<Preview: View, Destination: View>(
        destination: Destination,
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        actions: [UIAction] = []
    ) -> some View {
        modifier(
            PreviewContextViewModifier(
                destination: destination,
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }
    
    public func previewContextMenu<Preview: View>(
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        actions: [UIAction] = []
    ) -> some View {
        modifier(
            PreviewContextViewModifier<Preview, EmptyView>(
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }
    
    public func previewContextMenu<Destination: View>(
        destination: Destination,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        actions: [UIAction] = []
    ) -> some View {
        modifier(
            PreviewContextViewModifier<EmptyView, Destination>(
                destination: destination,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }

}


public struct PreviewContextViewModifier<Preview: View, Destination: View>: ViewModifier {
    @State private var isActive: Bool = false
    private let previewContent: Preview?
    private let destination: Destination?
    private let preferredContentSize: CGSize?
    private let actions: [UIAction]
    private let presentAsSheet: Bool
    
    /// destination and preview must be at least one exist
    init(destination: Destination? = nil,
         preview: Preview? = nil,
         preferredContentSize: CGSize? = nil,
         presentAsSheet: Bool = false,
         actions: [UIAction] = []) {
        self.destination = destination
        self.previewContent = preview
        self.preferredContentSize = preferredContentSize
        self.presentAsSheet = presentAsSheet
        self.actions = actions
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        ZStack {
            if !presentAsSheet, destination != nil {
                NavigationLink(
                    destination: destination,
                    isActive: $isActive,
                    label: { EmptyView() }
                )
                .hidden()
                .frame(width: 0, height: 0)
            }
            content
                .overlay(
                    PreviewContextView(
                        content: preview,
                        preferredContentSize: preferredContentSize,
                        actions: actions,
                        isPreviewOnly: destination == nil,
                        isActive: $isActive
                    )
                    .opacity(0.05)
                    .if(presentAsSheet) {
                        $0.sheet(isPresented: $isActive) {
                            destination
                        }
                    }
                )
        }
    }
    
    @ViewBuilder
    private var preview: some View {
        if let preview = previewContent {
            preview
        } else {
            destination
        }
    }
}


