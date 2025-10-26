import Foundation
import SwiftUI
import Combine

// MARK: - User Model
struct User: Codable, Identifiable {
    var id = UUID()
    let email: String
    let fullName: String
    let createdAt: Date
}

// MARK: - Authentication Manager
@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let authKey = "isAuthenticated"
    private let userKey = "currentUser"
    
    init() {
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        isAuthenticated = userDefaults.bool(forKey: authKey)
        if isAuthenticated {
            loadCurrentUser()
        }
    }
    
    private func loadCurrentUser() {
        if let userData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }
    
    private func saveCurrentUser(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: userKey)
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Simple validation (in real app, this would be server-side)
        if email.isEmpty && password.isEmpty {
            errorMessage = "Please fill in all fields"
            isLoading = false
            return
        } else if email.isEmpty {
            errorMessage = "Email is required"
            isLoading = false
            return
        } else if password.isEmpty {
            errorMessage = "Password is required"
            isLoading = false
            return
        }
        
        if !email.contains("@") {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        // Simulate successful login
        let user = User(email: email, fullName: email.components(separatedBy: "@").first ?? "User", createdAt: Date())
        currentUser = user
        saveCurrentUser(user)
        
        userDefaults.set(true, forKey: authKey)
        isAuthenticated = true
        isLoading = false
    }
    
    func register(fullName: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Validation
        if fullName.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            isLoading = false
            return
        }
        
        if !email.contains("@") {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        // Simulate successful registration
        let user = User(email: email, fullName: fullName, createdAt: Date())
        currentUser = user
        saveCurrentUser(user)
        
        userDefaults.set(true, forKey: authKey)
        isAuthenticated = true
        isLoading = false
    }
    
    func forgotPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        if email.isEmpty {
            errorMessage = "Please enter your email address"
            isLoading = false
            return
        }
        
        if !email.contains("@") {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        // Simulate successful password reset request
        isLoading = false
    }
    
    func logout() {
        userDefaults.set(false, forKey: authKey)
        userDefaults.removeObject(forKey: userKey)
        currentUser = nil
        isAuthenticated = false
    }
}