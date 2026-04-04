//
//  InfoView.swift
//  Flickr
//

import SwiftUI

struct InfoView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var iosVersion: String {
        UIDevice.current.systemVersion
    }

    var body: some View {
        ZStack {
            AppStyle.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "camera.aperture")
                        .font(.system(size: 56))
                        .foregroundStyle(AppStyle.tint)

                    Text("Flickr")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }

                VStack(spacing: 0) {
                    infoRow(title: "Version", value: "\(appVersion) (\(buildNumber))")

                    Divider()
                        .background(AppStyle.extraLightPurple)

                    infoRow(title: "iOS", value: iosVersion)
                }
                .background(AppStyle.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    InfoView()
}
