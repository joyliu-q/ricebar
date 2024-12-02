import SwiftUI

struct SettingsButton: View {
    @StateObject private var userSettings = UserSettings.shared
    
    var body: some View {
        DropdownButton(iconName: "gear", title: "Settings") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Shader Base Color")
                    .font(.caption)
                    .foregroundStyle(.defaultAccent)
                
                ColorPicker("", selection: $userSettings.shaderBaseColor)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .background(.defaultAccent)
                
                Text("Background Color")
                    .font(.caption)
                    .foregroundStyle(.defaultAccent)
                
                ColorPicker("", selection: $userSettings.backgroundColor)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
    }
} 