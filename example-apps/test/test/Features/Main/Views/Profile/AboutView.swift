import SwiftUI
import Combine

struct AboutView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Form {
            Section(header: Text("About")) {
                Text("This app is developed by Example Inc.")
            }
        }
        .navigationTitle("About")
    }
}


#Preview {
    AboutView()
        .environmentObject(AuthenticationManager())
}