//
//  ViewController.swift
//  Expense
//
//  Created by abhibhav Raj singh on 29/10/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    let loginService = LoginService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        statusLabel.numberOfLines = 0 // Allow unlimited lines
        statusLabel.lineBreakMode = .byWordWrapping
        setupKeyboardDismissHandling()
        
    }
    private func setupKeyboardDismissHandling() {
            // Add tap gesture to dismiss keyboard
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
        
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let username = usernameField.text, !username.isEmpty,
                      let password = passwordField.text, !password.isEmpty else {
                    statusLabel.text = "Please enter both username and password."
                    return
                }
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")

                // Call the login function
        loginService.loginUser(username: username, password: password) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let userResponse):
                            if userResponse.success {
                                if let id = userResponse.userId {
                                    UserDefaults.standard.set(id, forKey: "userId")
                                    print("User ID set: \(id)")
                                }
                                // Show success message
                                self?.statusLabel.text = "Login successful! Welcome, \(username)"
                                
                                // Navigate to DashboardViewController
                                self?.setRootToDashboard(userResponse: userResponse) // Pass the userResponse
                            } else {
                                self?.statusLabel.text = "Login failed: \(userResponse.message ?? "Unknown error")"
                            }
                        case .failure(let error):
                            self?.statusLabel.text = "Error: \(error.localizedDescription)"
                        }
                    }
                }
            }

            // Function to navigate to the DashboardViewController
    private func setRootToDashboard(userResponse: UserResponse) {
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            if let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
                dashboardVC.userResponse = userResponse
                
                // Create a new navigation controller with the dashboard as its root
                let navController = UINavigationController(rootViewController: dashboardVC)
                
                // Get the window scene
                if let windowScene = UIApplication.shared.connectedScenes
                    .first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    
                    // Set the new navigation controller as the root
                    window.rootViewController = navController
                    
                    // Add animation for smooth transition
                    UIView.transition(with: window,
                                    duration: 0.3,
                                    options: .transitionCrossDissolve,
                                    animations: nil,
                                    completion: nil)
                }
            }
        }
        }
