//
//  WifiButton.swift
//  ricebar
//
//  Created by Joy Liu on 12/5/24.
//
import SwiftUI

struct WifiButton: View {
    var wifiData: WifiData

    var body: some View {
        DropdownButton(iconName: "wifi", title: "Wi-Fi") {
            VStack(alignment: .leading, spacing: 4) {
                PasteBar(pasteContent: wifiData.ipv4, description: "IPv4:")
                Divider()
                PasteBar(pasteContent: wifiData.ipv6, description: "IPv6:")
            }
        }
    }
}

struct PasteBar: View {
    var pasteContent: String
    var description: String

    var body: some View {
        Button(action: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            let success = pasteboard.setString(pasteContent, forType: .string)
            if !success {
                print("Failed to copy to the clipboard")
            }
        }) {
            HStack {
                Text(description).foregroundStyle(.defaultAccent)
                Spacer()
                Text(pasteContent).foregroundStyle(.defaultAccent)
            }
        }
        .buttonStyle(.borderless)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        
    }
}
