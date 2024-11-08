//
//  AddExpenseViewController.swift
//  Expense
//
//  Created by abhibhav Raj singh on 01/11/24.
//

import UIKit

protocol AddExpenseDelegate: AnyObject {
    func didAddExpense(updatedExpenses: [Expense])
}

class AddExpenseViewController: UIViewController {
    weak var delegate: AddExpenseDelegate?

    // UI Elements
    let categoryPicker = UIPickerView()
    let titleTextField = UITextField()
    let amountTextField = UITextField()
    let datePicker = UIDatePicker()
    let addExpenseButton = UIButton(type: .system)

    // Sample categories
    let categories = ["Food", "Transport", "Entertainment", "Utilities", "Others"]
    var onExpenseAdded: (() -> Void)?
    
    // DateFormatter for formatting date
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust the format as needed
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "Add Expense"

        // Configure Title Text Field
        titleTextField.placeholder = "Expense title (e.g., Lunch)"
        titleTextField.borderStyle = .roundedRect
        titleTextField.backgroundColor = .white
        titleTextField.textColor = .black
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleTextField)

        // Configure Amount Text Field
        amountTextField.placeholder = "Enter the amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.backgroundColor = .white
        amountTextField.textColor = .black
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(amountTextField)

        // Configure Category Picker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryPicker)

        // Configure Date Picker
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)

        // Configure Add Expense Button
        addExpenseButton.setTitle("Add Expense", for: .normal)
        addExpenseButton.setTitleColor(.white, for: .normal) // Set button text color
        addExpenseButton.backgroundColor = .systemBlue // Button background color
        addExpenseButton.layer.cornerRadius = 5 // Rounded corners
        addExpenseButton.addTarget(self, action: #selector(addExpenseButtonTapped), for: .touchUpInside)
        addExpenseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addExpenseButton)

        // Set up constraints
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            amountTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            categoryPicker.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            categoryPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            datePicker.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addExpenseButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            addExpenseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func addExpenseButtonTapped() {
        addExpense()
    }

    private func addExpense() {
        guard let title = titleTextField.text, !title.isEmpty,
              let amountText = amountTextField.text, let amount = Double(amountText) else {
            // Optionally, show an alert if inputs are invalid
            return
        }

        let selectedRow = categoryPicker.selectedRow(inComponent: 0)
        guard selectedRow >= 0 && selectedRow < categories.count else {
            // Optionally, show an alert if the selected category index is out of bounds
            return
        }
        
        let category = categories[selectedRow]
        let date = datePicker.date
        
        let expense = Expense(expenseId: nil, category: category, title: title, amount: amount, date: dateFormatter.string(from: date))

        let loginService = LoginService()
        loginService.addExpense(expense: expense) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let userResponse):
                    print("Expense added successfully: \(userResponse)")
                    
                    // Get the current userId from UserDefaults
                    let id = UserDefaults.standard.integer(forKey: "id") // Ensure this matches your key
                    
                    // Fetch dashboard data instead of updated expenses
                    loginService.fetchDashboardData(id: id) { fetchResult in
                        DispatchQueue.main.async {
                            switch fetchResult {
                            case .success(let updatedUserResponse):
                                // Assuming the UserResponse contains the updated expenses
                                // Find the dashboard controller in the navigation stack
                                if let dashboardVC = self.navigationController?.viewControllers.first(where: { $0 is DashboardViewController }) as? DashboardViewController {
                                    // Update the expenses array
                                    dashboardVC.expenses = updatedUserResponse.expenses ?? []
                                    
                                    // Pop back to dashboard
                                    self.navigationController?.popViewController(animated: true)
                                    
                                    // Force the table view to reload after a small delay to ensure the view is visible
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        dashboardVC.expensesTableView.reloadData()
                                        dashboardVC.displayUserData() // Refresh the dashboard labels
                                    }
                                }
                                
                            case .failure(let error):
                                // Handle the error - just log it without showing an alert
                                print("Failed to fetch dashboard data: \(error.localizedDescription)")
                                // Optionally, you can perform other error handling here, like logging or updating the UI.
                            }
                        }
                    }
                    
                case .failure(let error):
                    // Handle the error appropriately (e.g., show an alert)
                    print("Failed to add expense: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UIPickerView Delegate & Data Source
extension AddExpenseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}
