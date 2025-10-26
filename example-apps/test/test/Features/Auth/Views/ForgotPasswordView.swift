import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var showingSuccessMessage = false
    @FocusState private var isEmailFocused: Bool
    
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Forgot Password?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Don't worry, we'll send you reset instructions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    if showingSuccessMessage {
                        // Success Message
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Reset Link Sent!")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("We've sent a password reset link to \(email). Please check your email and follow the instructions to reset your password.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button("Back to Login") {
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 32)
                    } else {
                        // Reset Form
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email Address")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($isEmailFocused)
                                    .onSubmit {
                                        if isValidEmail {
                                            Task {
                                                await sendResetLink()
                                            }
                                        }
                                    }
                                
                                if !email.isEmpty && !isValidEmail {
                                    Text("Please enter a valid email address")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            
                            // Error Message
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Send Reset Link Button
                            Button(action: {
                                Task {
                                    await sendResetLink()
                                }
                            }) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Send Reset Link")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(isValidEmail ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(authManager.isLoading || !isValidEmail)
                            
                            // Additional Help
                            VStack(spacing: 12) {
                                Text("Remember your password?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button("Back to Login") {
                                    dismiss()
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            }
                            .padding(.top, 20)
                        }
                        .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onTapGesture {
            isEmailFocused = false
        }
    }
    
    private func sendResetLink() async {
        await authManager.forgotPassword(email: email)
        if authManager.errorMessage == nil {
            withAnimation {
                showingSuccessMessage = true
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthenticationManager())
}