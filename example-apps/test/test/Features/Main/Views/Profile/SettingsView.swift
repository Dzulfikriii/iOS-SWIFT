import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var enableNotifications = true
    @State private var useBiometrics = false
    @State private var reduceMotion = false
    
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(authManager.currentUser?.fullName ?? "User")
                        Text(authManager.currentUser?.email ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Button(role: .destructive) {
                    authManager.logout()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            Section(header: Text("Preferences")) {
                Toggle("Enable Notifications", isOn: $enableNotifications)
                Toggle("Use Biometrics", isOn: $useBiometrics)
                Toggle("Reduce Motion", isOn: $reduceMotion)
            }
            Section(header: Text("About")) {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AuthenticationManager())
    }
}