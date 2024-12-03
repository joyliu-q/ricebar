//
//  MenuBarView.swift
//  ricebar
//
//  Created by Joy Liu on 11/9/24.
//
import SwiftUI

struct MenuBarView: View {
    let onDismiss: () -> Void
    @State private var showPing = false
    @State private var batteryPercentage = SystemInfoProvider.getBatteryPercentage()
    @State private var cpuUtilization = SystemInfoProvider.getCPUUtilization()
    @State private var isCharging = SystemInfoProvider.isCharging()
    @State private var wifiDropdownExpanded = false
    @State private var wifiData = SystemInfoProvider.getWifiData()

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
                
                DropdownButton(iconName: "wifi", title: "Wi-Fi") {
                    VStack(alignment: .leading, spacing: 4) {
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            let success = pasteboard.setString(wifiData.ipv4, forType: .string)
                            if !success {
                                print("Failed to copy IPv4 address to the clipboard")
                            }
                        }) {
                            HStack {
                                Text("IPv4:")
                                Spacer()
                                Text(wifiData.ipv4)
                            }
                        }
                        .buttonStyle(.borderless)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            let success = pasteboard.setString(wifiData.ipv6, forType: .string)
                            if !success {
                                print("Failed to copy IPv6 address to the clipboard")
                            }
                        }) {
                            HStack {
                                Text("IPv6:")
                                Spacer()
                                Text(wifiData.ipv6)
                            }
                        }
                        .buttonStyle(.borderless)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                ReminderButton()

               ActionButton(iconName: "sparkles") {
                   showPing = true
               }
               .alert(isPresented: $showPing) {
                   Alert(title: Text("Ping"), message: Text("Pong"), dismissButton: .default(Text("OK")))
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
            .shadow(radius: 10)
            .onAppear {
                batteryPercentage = SystemInfoProvider.getBatteryPercentage()
                cpuUtilization = SystemInfoProvider.getCPUUtilization()
                isCharging = SystemInfoProvider.isCharging()
            }
        }.padding(5)
        .background(.clear)
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
