import SwiftUI
import Combine

struct HelpAndSupportView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Form {
            Section(header: Text("Help and Support")) {
                Text("Contact us at support@example.com")
            }
        }
        .navigationTitle("Help and Support")
    }
}



#Preview {
    HelpAndSupportView()
        .environmentObject(AuthenticationManager())
}