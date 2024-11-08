import Foundation

struct UserResponse: Codable {
    let success: Bool
    let userId: Int? // Changed from userId to id
    let username: String?
    let allowance: Double?
    let totalExpenses: Double?
    let remainingAllowance: Double?
    let message: String?
    let expenses: [Expense]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case userId // Changed from userId to id
        case username
        case allowance
        case totalExpenses
        case remainingAllowance
        case message
        case expenses
    }
}

struct Expense: Codable {
    let expenseId: Int? // Changed from id to expense_id
    let category: String
    let title: String
    let amount: Double
    let date: String
    
    var isPreviousExpense: Bool {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let expenseDate = formatter.date(from: date) else { return false }
            return expenseDate < Date()
        }
    
    enum CodingKeys: String, CodingKey {
        case expenseId = "id" // Map the JSON key "id" to the property "expenseId"
        case category
        case title
        case amount
        case date
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case serverError(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

class LoginService {
    typealias LoginCompletion = (Result<UserResponse, Error>) -> Void
    
    func loginUser(username: String, password: String, completion: @escaping LoginCompletion) {
        guard let url = URL(string: " https://5f15-2401-4900-1c0b-8725-741b-195e-b21c-1e7f.ngrok-free.app/expensetracker-1.0-SNAPSHOT/login") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "username=\(username)&password=\(password)"
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Login error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1001, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print(noDataError.localizedDescription)
                completion(.failure(noDataError))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let statusError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode)"])
                print(statusError.localizedDescription)
                completion(.failure(statusError))
                return
            }
            
            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                if userResponse.success, let id = userResponse.userId {
                    UserDefaults.standard.set(id, forKey: "userId")
                    UserDefaults.standard.synchronize()
                    completion(.success(userResponse))
                } else {
                    completion(.success(userResponse))
                }
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func addExpense(expense: Expense, completion: @escaping LoginCompletion) {
        guard let url = URL(string: "https://5f15-2401-4900-1c0b-8725-741b-195e-b21c-1e7f.ngrok-free.app/expensetracker-1.0-SNAPSHOT/addExpense") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "mobileAction=addExpense&category=\(expense.category)&title=\(expense.title)&amount=\(expense.amount)&date=\(expense.date)"
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding expense: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusError = NSError(domain: "ServerError", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)
                print("Error: \(statusError.localizedDescription)")
                completion(.failure(statusError))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1001, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print(noDataError.localizedDescription)
                completion(.failure(noDataError))
                return
            }
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw server response: \(rawResponse)")
            }
            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(userResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchPreviousExpenses(startDate: String, endDate: String, completion: @escaping (Result<[Expense], Error>) -> Void) {
        guard let url = URL(string: " https://5f15-2401-4900-1c0b-8725-741b-195e-b21c-1e7f.ngrok-free.app/expensetracker-1.0-SNAPSHOT/expenses") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = "mobileAction=getPreviousExpenses&startDate=\(startDate)&endDate=\(endDate)"
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching previous expenses: \(error)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let statusError = NSError(domain: "ServerError", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)
                    print("Error: \(statusError.localizedDescription)")
                    completion(.failure(statusError))
                    return
                }

                guard let data = data else {
                    let noDataError = NSError(domain: "", code: -1001, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    print(noDataError.localizedDescription)
                    completion(.failure(noDataError))
                    return
                }

            do {
                        // Parse the JSON response
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let previousExpensesArray = jsonResponse?["previousExpenses"] as? [[String: Any]] {
                    var prevExpenses: [Expense] = []
                    for expenseDict in previousExpensesArray {
                        if let expenseId = expenseDict["id"] as? Int,
                           let category = expenseDict["category"] as? String,
                            let title = expenseDict["title"] as? String,
                            let amount = expenseDict["amount"] as? Double,
                            let date = expenseDict["date"] as? String {
                            let prevExpense = Expense(expenseId: expenseId, category: category, title: title, amount:amount, date: date)
                                prevExpenses.append(prevExpense)
                            }
                        }
                        completion(.success(prevExpenses))
                    } else {
                        throw NSError(domain: "DataParsingError", code: -1002, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])
                    }
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }

            task.resume()
        }

    func fetchDashboardData(id: Int, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard let url = URL(string: "https://5f15-2401-4900-1c0b-8725-741b-195e-b21c-1e7f.ngrok-free.app/expensetracker-1.0-SNAPSHOT/dashboard") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "id", value: "\(id)")]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("true", forHTTPHeaderField: "X-Mobile-App")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Log the raw JSON response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(rawResponse)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let userResponse = try decoder.decode(UserResponse.self, from: data)
                completion(.success(userResponse))
            } catch {
                print("Decoding error: \(error)") // Debug print for decoding errors
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
