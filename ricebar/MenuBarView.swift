//
//  MenuBarView.swift
//  ricebar
//
//  Created by Joy Liu on 11/9/24.
//
import SwiftUI
import IOKit.ps
import IOKit
//  MenuBarView.swift
//  ricebar
//
//  Created by Joy Liu on 11/9/24.
//
import SwiftUI
import IOKit.ps
import IOKit

struct MenuBarView: View {
    let onDismiss: () -> Void
    @State private var showAlert = false
    @State private var batteryPercentage = SystemInfoProvider.getBatteryPercentage()
    @State private var cpuUtilization = SystemInfoProvider.getCPUUtilization()
    @State private var isCharging = SystemInfoProvider.isCharging()

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ZStack(alignment: .topTrailing) {
                    SystemInfoButton(iconName: SystemInfoProvider.getBatteryIcon(for: batteryPercentage), label: "\(batteryPercentage)%")
                    
                    if isCharging {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                            .offset(x: -5, y: -5)
                    }
                }
                
                SystemInfoButton(iconName: nil, label: SystemInfoProvider.getCurrentTime())
                SystemInfoButton(iconName: SystemInfoProvider.getCPUIcon(for: cpuUtilization), label: "\(cpuUtilization)%")

                ActionButton(iconName: "rectangle.stack") {
                    SystemActions.openActivityMonitor()
                }

                ActionButton(iconName: "bell") {
                    showAlert = true
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Hi"), message: Text("This is a simple alert!"), dismissButton: .default(Text("OK")))
                }

                Spacer()
                Button("Dismiss") {
                    onDismiss()
                }
                .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(DEFAULT_BACKGROUND)
            .cornerRadius(16)
            .shadow(radius: 10)
            .onAppear {
                batteryPercentage = SystemInfoProvider.getBatteryPercentage()
                cpuUtilization = SystemInfoProvider.getCPUUtilization()
                isCharging = SystemInfoProvider.isCharging()
            }
        }.padding(5)
    }
}

struct SystemInfoProvider {
    static func getBatteryPercentage() -> Int {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !sources.isEmpty,
              let source = sources.first,
              let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any],
              let currentCapacity = description[kIOPSCurrentCapacityKey as String] as? Int,
              let maxCapacity = description[kIOPSMaxCapacityKey as String] as? Int else {
            return -1
        }
        return Int((Double(currentCapacity) / Double(maxCapacity)) * 100)
    }

    static func isCharging() -> Bool {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !sources.isEmpty,
              let source = sources.first,
              let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any],
              let isCharging = description[kIOPSIsChargingKey as String] as? Bool else {
            return false
        }
        return isCharging
    }

    static func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    static func getCPUUtilization() -> Int {
        var loadArray = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: loadArray) / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &loadArray) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return -1 }

        let user = Double(loadArray.cpu_ticks.0)
        let system = Double(loadArray.cpu_ticks.1)
        let idle = Double(loadArray.cpu_ticks.2)
        let nice = Double(loadArray.cpu_ticks.3)
        let totalTicks = user + system + idle + nice

        let usagePercentage = ((user + system + nice) / totalTicks) * 100
        return Int(usagePercentage)
    }

    static func getBatteryIcon(for percentage: Int) -> String {
        switch percentage {
        case 81...100:
            return "battery.100"
        case 61...80:
            return "battery.75"
        case 41...60:
            return "battery.50"
        case 21...40:
            return "battery.25"
        case 0...20:
            return "battery.0"
        default:
            return "battery.slash"
        }
    }

    static func getCPUIcon(for utilization: Int) -> String {
        switch utilization {
        case 0...20:
            return "cpu"
        case 21...50:
            return "cpu.fill"
        case 51...100:
            return "cpu.warning"
        default:
            return "exclamationmark.triangle"
        }
    }
}

struct SystemActions {
    static func openActivityMonitor() {
        let path = "/Applications/Utilities/Activity Monitor.app"
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }
}

#Preview {
    MenuBarView {}
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
