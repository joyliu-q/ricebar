//
//  ReminderButton.swift
//  ricebar
//
//  Created by Joy Liu on 11/17/24.
//


import SwiftUI
import UserNotifications

struct ReminderButton: View {
    @State private var selectedMinutes: String = "5"
    @State private var customMessage: String = ""
    @State private var reminders: [(id: UUID, time: Date, message: String)] = []

    let reminderOptions = ["1", "5", "10", "15", "30", "60"]

    var body: some View {
        VStack {
            DropdownButton(iconName: "bell", title: "Set Reminder") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Remind me in:")
                        Picker(selection: $selectedMinutes, label: Text("Minutes")) {
                            ForEach(reminderOptions, id: \.self) { option in
                                Text("\(option) min").tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    TextField("Optional message", text: $customMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: requestNotificationPermission) {
                        HStack {
                            Text("Set Reminder")
                                .foregroundColor(.white)
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    if !reminders.isEmpty {
                        Text("Ongoing Reminders:")
                            .font(.headline)
                        List {
                            ForEach(reminders, id: \.id) { reminder in
                                VStack(alignment: .leading) {
                                    Text(reminder.message.isEmpty ? "No Message" : reminder.message)
                                        .font(.body)
                                    Text("Time: \(formattedDate(reminder.time))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(height: 100)
                    }
                }
                .padding()
            }
            .onAppear(perform: removeExpiredReminders)

            
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                setReminder()
            } else {
                print("Notification permissions denied: \(String(describing: error))")
            }
        }
    }

    private func setReminder() {
        guard let minutes = Int(selectedMinutes) else { return }
        let reminderTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
        let message = customMessage.isEmpty ? "Time's up!" : customMessage
        let reminderID = UUID()

        reminders.append((id: reminderID, time: reminderTime, message: message))
        scheduleNotification(id: reminderID, message: message, date: reminderTime)
        customMessage = ""
    }

    private func scheduleNotification(id: UUID, message: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    private func removeExpiredReminders() {
        let now = Date()
        reminders.removeAll { $0.time < now }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
