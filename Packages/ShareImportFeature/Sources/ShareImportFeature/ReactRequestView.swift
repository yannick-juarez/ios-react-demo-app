//
//  ReactRequestView.swift
//  React
//
//  Created by Yannick Juarez on 27/04/2026.
//

import SwiftUI
import UIKit
import CoreDomain
import DesignSystem

public struct ReactRequestView: View {

    public let sharedImage: UIImage
    public let onCancel: () -> Void
    public let onContinue: (String) -> Void

    public var cornerRadius: CGFloat = 8

    @State private var hintText: String = ""
    @State private var searchQuery: String = ""
    @State private var reactMandatory: Bool = true
    @State private var showReactMandatoryAlert: Bool = false

    public var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Share content with React")
                    .font(.title3.bold())
            }
            .padding(.top)

            HStack {
                Image(uiImage: self.sharedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 62)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: self.cornerRadius)
                            .stroke(.white.opacity(0.4), lineWidth: 1)
                    }
                    .padding(.horizontal, 8)

                VStack {
                    TextField("Add a hint...", text: self.$hintText)
                        .padding(8)
                        .padding(.horizontal, 8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))

                    Toggle("React mandatory", isOn: self.$reactMandatory)
                }
            }
            .padding(.horizontal)

            VStack {
                HStack {
                    Text("To:")
                        .foregroundStyle(.primary)
                    TextField("Search friends...", text: self.$searchQuery)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))

                Button {

                } label: {
                    HStack {
                        Image(systemName: "person.2.badge.plus.fill")
                        Text("Create a new group")
                        Text("(Mockup)")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .foregroundStyle(.primary)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
            }
            .padding(.horizontal)

            List {
                Section(header: Text("Selected")) {
                    SelectableUser(selected: true)
                }
                Section(header: Text("A")) {
                    ForEach(0..<3) { _ in
                        SelectableUser()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(.clear)

            HStack(spacing: 12) {
                Button("Cancel") {
                    self.onCancel()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.thinMaterial)
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Share") {
                    self.onContinue(self.hintText)
                }
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .onChange(of: self.reactMandatory) { newValue in
            guard newValue == false else { return }
            self.showReactMandatoryAlert = true
        }
        .alert("React is mandatory", isPresented: self.$showReactMandatoryAlert) {
            Button("OK", role: .cancel) {
                self.reactMandatory = true
            }
        } message: {
            Text("This is a demo app, so the React option is mandatory.")
        }
    }

    func SelectableUser(selected: Bool = false) -> some View {
        HStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Text("YJ")
                        .font(.caption.bold())
                }

            Text("Yaya")

            Spacer()

            if selected {
                Circle()
                    .fill()
                    .frame(width: 20, height: 20)
            } else {
                Circle()
                    .stroke()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

#Preview {
    ReactRequestView(
        sharedImage: UIImage(systemName: "photo")!,
        onCancel: {},
        onContinue: { _ in }
    )
    .preferredColorScheme(.dark)
}
