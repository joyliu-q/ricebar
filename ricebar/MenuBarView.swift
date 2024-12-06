//
//  MenuBarView.swift
//  ricebar
//
//  Created by Joy Liu on 11/9/24.
//
import SwiftUI

struct MenuBarView: View {
    let onDismiss: () -> Void
    var pongWindowField: NSWindow? {
        let pongWindowField = NSWindow(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        pongWindowField.title = "Pong"
        pongWindowField.level = .mainMenu
        pongWindowField.backgroundColor = .clear
        pongWindowField.isOpaque = false
        pongWindowField.hasShadow = false
        pongWindowField.contentView = NSHostingView(rootView: PongView())
        
        return pongWindowField
    }
    
    @State private var showPing = false
    @State private var batteryPercentage = SystemInfoProvider.getBatteryPercentage()
    @State private var cpuUtilization = SystemInfoProvider.getCPUUtilization()
    @State private var isCharging = SystemInfoProvider.isCharging()
    @State private var wifiDropdownExpanded = false
    @State private var wifiData = SystemInfoProvider.getWifiData()
    @State private var showPong = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ZStack(alignment: .topTrailing) {
                Button(action: {}) {
                    HStack {
                        ZStack {
                            Image(systemName: SystemInfoProvider.getBatteryIcon(for: batteryPercentage))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            
                            if (isCharging) {
                                Image(systemName: "bolt.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.blue)
                                    .offset(x: -2)
                            }
                        }
                        
                    }.modifier(
                        ConditionalModifier(
                            condition: isCharging,
                            trueModifier: TimeVaryingShader()
                        )
                    )
                    
                        Text("\(batteryPercentage)%")
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                
                WeatherButton()
                SystemInfoButton(iconName: nil, label: SystemInfoProvider.getCurrentTime())
                SystemInfoButton(iconName: SystemInfoProvider.getCPUIcon(for: cpuUtilization), label: "\(cpuUtilization)%")

                ActionButton(iconName: "book.and.wrench") {
                    SystemActions.openActivityMonitor()
                }
                
                ReminderButton()
                
                WifiButton(wifiData: wifiData)

                ActionButton(iconName: "sparkles") {
                    showPing = true
                }
                .alert(isPresented: $showPing) {
                    Alert(title: Text("Ping"), message: Text("Pong"), dismissButton: .default(Text("OK")))
                }

               ActionButton(iconName: "gamecontroller") {
                   showPong = true
                   pongWindowField?.makeKeyAndOrderFront(nil)
                   
                   if let position = PopoverManager.shared.popoverWindow?.frame.midX {
                       PongView.updatePaddlePosition(position)
                   }
               }

                SettingsButton()

                Spacer()
                ActionButton(iconName: "chevron.forward.dotted.chevron.forward") {
                    onDismiss()
                }
                .foregroundColor(.white)
            }
            .padding(EdgeInsets(top: 4, leading: 12, bottom:4, trailing: 12))
            .frame(maxWidth: .infinity)
            .background(DEFAULT_BACKGROUND.timeVaryingShader())
            .cornerRadius(16)
        }
        .padding(5)
        .background(.clear)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SystemInfoButton: View {
    let iconName: String?
    let label: String

    var body: some View {
        Button(action: {}) {
            HStack {
                if iconName != nil {
                    Image(systemName: iconName!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
                Text(label)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionButton: View {
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MenuBarView {}
}
