//
//  DashboardViewController.swift
//  Expense
//
//  Created by Abhibhav Raj Singh on 30/10/24.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Outlets for your UI elements (e.g., labels, tables)
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var allowanceLabel: UILabel!
    @IBOutlet weak var totalExpensesLabel: UILabel!
    @IBOutlet weak var remainingAllowanceLabel: UILabel!
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var addExpense: UIButton!
    @IBOutlet weak var prevExpenses: UIButton!
    
    // You can add more UI elements as neede

    var userResponse: UserResponse? // Store the fetched user response
    let loginService = LoginService()
    private var menuView: UIView!
    private var menuButton: UIButton!
    private var isMenuVisible = false
    private var menuOptions: [(title: String, action: Selector)] = []
    var expenses: [Expense] = []
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var startDatePicker: UIDatePicker!
    private var endDatePicker: UIDatePicker!
    private var dateSelectionView: UIView!
    private var submitButton: UIButton!

    override func viewDidLoad() {
            super.viewDidLoad()
           // refreshData()
            navigationController?.setNavigationBarHidden(false, animated: false)
            //expensesTableView.backgroundColor = .white
            expensesTableView.separatorColor = .lightGray
            expensesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExpenseCell")
            expensesTableView.dataSource = self
            expensesTableView.delegate = self
            
            // Temporary mock data to test table view
            /*self.expenses = [
                Expense(date: "16/08/2024", amount: 100, title: "Test Expense 1"),
                Expense(date: "16/08/2023", amount: 200, title: "Test Expense 2")
            ]*/
            expensesTableView.reloadData()
            
            configureNavigationBar()
            setupMenu()
            displayUserData()
            setupUI()
            setupRefreshControl()
            fetchInitialData()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData() // This will fetch and update the expenses when returning to the screen
    }
    func refreshData() {
        // Assuming 'userId' is stored as part of UserDefaults after login
        if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
            let loginService = LoginService()
            loginService.fetchDashboardData(id: userId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let userResponse):
                        if let updatedExpenses = userResponse.expenses {
                            // Update the UI with new expenses data
                            self?.expenses = updatedExpenses
                            self?.expensesTableView.reloadData() // Corrected line
                        } else {
                            print("No expenses found for user ID: \(userId)")
                        }
                    case .failure(let error):
                        print("Failed to fetch dashboard data: \(error)")
                    }
                }
            }
        } else {
            print("User ID not found. Cannot refresh data.")
        }
    }



        // TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of expenses:", expenses.count)  // Debug: Check expenses count
        return expenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ExpenseCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // Check if the labels are already set up; if not, set them up
        if cell.contentView.viewWithTag(1) == nil {
            // Title label
            let titleLabel = UILabel()
            titleLabel.tag = 1 // Use tags to identify the label later
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(titleLabel)
            
            // Amount label
            let amountLabel = UILabel()
            amountLabel.tag = 2
            amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            amountLabel.textAlignment = .right
            amountLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(amountLabel)
            
            // Date label
            let dateLabel = UILabel()
            dateLabel.tag = 3
            dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(dateLabel)
            
            // Set up Auto Layout constraints
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
                titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                
                amountLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
                amountLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                
                dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
                dateLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
            ])
        }

        // Retrieve existing labels using tags and update them
        if let titleLabel = cell.contentView.viewWithTag(1) as? UILabel {
            titleLabel.text = expenses[indexPath.row].title
        }
        if let amountLabel = cell.contentView.viewWithTag(2) as? UILabel {
            amountLabel.text = "\(expenses[indexPath.row].amount)"
        }
        if let dateLabel = cell.contentView.viewWithTag(3) as? UILabel {
            dateLabel.text = expenses[indexPath.row].date
        }

        return cell
    }
    @IBAction func addExpenseButtonTapped(_ sender: UIButton) {
        let addExpenseVC = AddExpenseViewController()
        navigationController?.pushViewController(addExpenseVC, animated: true)
    }


        private func configureNavigationBar() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            
            // Configure menu button
            menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
            menuButton.tintColor = .systemBlue
            menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
            
            let leftBarButton = UIBarButtonItem(customView: menuButton)
            navigationItem.leftBarButtonItem = leftBarButton
            title = "Dashboard"
        }
    @IBAction func prevExpensesButtonTaped(_ sender: UIButton) {
        showDateSelectionView()
    }
    

       private func showDateSelectionView() {
           UIView.animate(withDuration: 0.3) {
               self.dateSelectionView.frame.origin.y = self.view.frame.height - 300
           }
       }

    @objc private func fetchPreviousExpenses() {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let startDate = formatter.string(from: startDatePicker.date)
            let endDate = formatter.string(from: endDatePicker.date)
        
            guard startDate <= endDate else {
                print("Error: Start date cannot be later than the end date.")
                // Optionally, display an alert to inform the user
                let alert = UIAlertController(title: "Invalid Date Range", message: "The start date cannot be later than the end date.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            let loginService = LoginService()
            loginService.fetchPreviousExpenses(startDate: startDate, endDate: endDate) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let expenses):
                        print("Fetched previous expenses: \(expenses)")
                        // Handle displaying the fetched expenses as needed
                    case .failure(let error):
                        print("Failed to fetch previous expenses: \(error.localizedDescription)")
                        // Show an alert or handle the error
                    }
                }
            }

           // Animate the dateSelectionView out of view
           UIView.animate(withDuration: 0.3) {
               self.dateSelectionView.frame.origin.y = self.view.frame.height
           }
       }
    private func setupDateSelectionView() {
           // Create a container view for the date pickers and submit button
           dateSelectionView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300))
           dateSelectionView.backgroundColor = .systemBackground
           dateSelectionView.layer.cornerRadius = 10

           // Create start date picker
           startDatePicker = UIDatePicker()
           startDatePicker.datePickerMode = .date
           startDatePicker.translatesAutoresizingMaskIntoConstraints = false
           dateSelectionView.addSubview(startDatePicker)

           // Create end date picker
           endDatePicker = UIDatePicker()
           endDatePicker.datePickerMode = .date
           endDatePicker.translatesAutoresizingMaskIntoConstraints = false
           dateSelectionView.addSubview(endDatePicker)

           // Create submit button
           submitButton = UIButton(type: .system)
           submitButton.setTitle("Fetch Previous Expenses", for: .normal)
           submitButton.translatesAutoresizingMaskIntoConstraints = false
           submitButton.addTarget(self, action: #selector(fetchPreviousExpenses), for: .touchUpInside)
           dateSelectionView.addSubview(submitButton)

           // Add the dateSelectionView to the main view
           view.addSubview(dateSelectionView)

           // Set up constraints
           NSLayoutConstraint.activate([
               startDatePicker.topAnchor.constraint(equalTo: dateSelectionView.topAnchor, constant: 20),
               startDatePicker.leadingAnchor.constraint(equalTo: dateSelectionView.leadingAnchor, constant: 20),
               startDatePicker.trailingAnchor.constraint(equalTo: dateSelectionView.trailingAnchor, constant: -20),

               endDatePicker.topAnchor.constraint(equalTo: startDatePicker.bottomAnchor, constant: 20),
               endDatePicker.leadingAnchor.constraint(equalTo: dateSelectionView.leadingAnchor, constant: 20),
               endDatePicker.trailingAnchor.constraint(equalTo: dateSelectionView.trailingAnchor, constant: -20),

               submitButton.topAnchor.constraint(equalTo: endDatePicker.bottomAnchor, constant: 20),
               submitButton.centerXAnchor.constraint(equalTo: dateSelectionView.centerXAnchor)
           ])
       }

        private func setupMenu() {
            menuView = UIView()
            menuView.backgroundColor = UIColor.systemBackground
            menuView.layer.shadowColor = UIColor.black.cgColor
            menuView.layer.shadowOpacity = 0.3
            menuView.layer.shadowRadius = 5
            view.addSubview(menuView)

            menuView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                menuView.topAnchor.constraint(equalTo: view.topAnchor),
                menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                menuView.widthAnchor.constraint(equalToConstant: 250),
                menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -250)
            ])
            
            menuOptions = [("Dashboard", #selector(dashboardTapped)), ("Logout", #selector(logoutTapped))]
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.translatesAutoresizingMaskIntoConstraints = false
            menuView.addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 100),
                stackView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -20)
            ])
            
            for (index, option) in menuOptions.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(option.title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 18)
                button.contentHorizontalAlignment = .left
                button.addTarget(self, action: option.action, for: .touchUpInside)

                if index == 0 {
                    button.setTitleColor(.systemBlue, for: .normal)
                }
                
                stackView.addArrangedSubview(button)
            }
            
            menuView.isHidden = true
        }

        @objc private func menuButtonTapped() {
            isMenuVisible.toggle()
            let imageName = isMenuVisible ? "xmark" : "line.horizontal.3"
            menuButton.setImage(UIImage(systemName: imageName), for: .normal)

            if menuView.isHidden {
                menuView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3) {
                self.menuView.transform = self.isMenuVisible ? CGAffineTransform(translationX: 250, y: 0) : .identity
            } completion: { _ in
                if !self.isMenuVisible {
                    self.menuView.isHidden = true
                }
            }
        }

        @objc private func dashboardTapped() {
            handleMenuSelection(index: 0)
        }

        @objc private func logoutTapped() {
            handleMenuSelection(index: 1)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateInitialViewController()
                window.rootViewController = loginVC
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }

        private func handleMenuSelection(index: Int) {
            menuButtonTapped()

            if let stackView = menuView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
                stackView.arrangedSubviews.enumerated().forEach { (idx, view) in
                    if let button = view as? UIButton {
                        button.setTitleColor(idx == index ? .systemBlue : .systemGray, for: .normal)
                    }
                }
            }
        }
    private func setupUI() {
           // Setup loading indicator
           loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(loadingIndicator)
           
           NSLayoutConstraint.activate([
               loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
           ])
           
           // Setup table view
           expensesTableView.dataSource = self
           expensesTableView.delegate = self
           expensesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExpenseCell")
       }
       
       private func setupRefreshControl() {
           refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
           refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
           expensesTableView.refreshControl = refreshControl
       }
       
       private func fetchInitialData() {
           loadingIndicator.startAnimating()
           fetchDashboardData()
       }
       
       @objc private func handleRefresh() {
           fetchDashboardData()
       }
       
       private func fetchDashboardData() {
           guard let userId = UserDefaults.standard.value(forKey: "userId") as? Int else {
               showError(message: "User ID not found. Please log in again.")
               endRefreshing()
               return
           }
           
           loginService.fetchDashboardData(id: userId) { [weak self] result in
               DispatchQueue.main.async {
                   guard let self = self else { return }
                   
                   self.loadingIndicator.stopAnimating()
                   self.endRefreshing()
                   
                   switch result {
                   case .success(let response):
                       self.updateUI(with: response)
                   case .failure(let error):
                       self.handleError(error)
                   }
               }
           }
       }
       
       private func updateUI(with response: UserResponse) {
           // Update labels
           usernameLabel.text = "Welcome, \(response.username ?? "Guest")"
           allowanceLabel.text = "Allowance: $\(String(format: "%.2f", response.allowance ?? 0))"
           totalExpensesLabel.text = "Total Expenses: $\(String(format: "%.2f", response.totalExpenses ?? 0))"
           remainingAllowanceLabel.text = "Remaining: $\(String(format: "%.2f", response.remainingAllowance ?? 0))"
           
           // Update expenses and table
           if let userExpenses = response.expenses {
               expenses = userExpenses
               expensesTableView.reloadData()
           }
           
           // Animate the updates
           UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
           }
       }
       
       private func handleError(_ error: Error) {
           var message = "An error occurred while refreshing data."
           
           if let networkError = error as? NetworkError {
               message = networkError.localizedDescription
           } else {
               message = error.localizedDescription
           }
           
           showError(message: message)
       }
       
       private func showError(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
       
       private func endRefreshing() {
           refreshControl.endRefreshing()
           loadingIndicator.stopAnimating()
       }

        func displayUserData() {
            guard let userResponse = userResponse else {
                print("No user response data available")
                return
            }

            print("Parsed User Data:")
            print("Username: \(userResponse.username ?? "Unknown")")
            print("Allowance: \(userResponse.allowance ?? 0)")
            print("Total Expenses: \(userResponse.totalExpenses ?? 0)")
            print("Remaining Allowance: \(userResponse.remainingAllowance ?? 0)")

            usernameLabel.text = "Welcome, \(userResponse.username ?? "Guest")"
            allowanceLabel.text = "Allowance: \(userResponse.allowance ?? 0)"
            totalExpensesLabel.text = "Total Expenses: \(userResponse.totalExpenses ?? 0)"
            remainingAllowanceLabel.text = "Remaining Allowance: \(userResponse.remainingAllowance ?? 0)"

            if let userExpenses = userResponse.expenses {
                self.expenses = userExpenses
                print("Expenses found: \(self.expenses.count)")
            } else {
                print("No expenses found in JSON response.")
                self.expenses = []
            }

            expensesTableView.reloadData()
        }
        
    }
