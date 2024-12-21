import Foundation
import FirebaseCore
import FirebaseAuth

class FirebaseManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    
    static let shared = FirebaseManager()
    
    private init() {
        // Configure Firebase first
        FirebaseApp.configure()
        
        // Then check login state and set up listener
        isLoggedIn = Auth.auth().currentUser != nil
        currentUser = Auth.auth().currentUser
        
        // Add auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = user != nil
                self?.currentUser = user
            }
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = authResult.user
                self.isLoggedIn = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = authResult.user
                self.isLoggedIn = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.currentUser = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
} 