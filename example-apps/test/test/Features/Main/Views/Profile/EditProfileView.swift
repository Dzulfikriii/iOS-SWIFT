import SwiftUI
import Combine

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var fullName = ""
    @State private var email = ""
    
    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                TextField("Full Name", text: $fullName)
                TextField("Email", text: $email)
            }
        }
        .navigationTitle("Edit Profile")
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthenticationManager())
}