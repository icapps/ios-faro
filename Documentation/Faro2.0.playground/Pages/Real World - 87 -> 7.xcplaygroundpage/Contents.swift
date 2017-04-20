import Foundation

// MARK: - Authenticate

enum ConnectiveError: Error {
	case invalidBase64Hash
}
enum Result {
	case success(Any)
	case failure(ConnectiveError)

	var error: ConnectiveError? {
		switch self {
		case .failure(let error):
			return error
		default:
			return nil
		}
	}

}

func beginTransaction() -> Result {
	return .success("")
}

func setAuthenticationSecurityEnvironment() -> Result {
	return .success("")
}
func verifyPin() -> Result {
	return .success("")
}

func sign(data: Data) -> Result {
	return .success(data)
}

let connectiveQueue = DispatchQueue(label: "Connective")

func authenticate(documentHash: String, completionHandler: @escaping (_ result: Result) -> Void) {
	connectiveQueue.async {

		// Check if the document hash is valid.
		guard let data = Data(base64Encoded: documentHash, options: .ignoreUnknownCharacters) else {
			DispatchQueue.main.async {
				completionHandler(.failure(.invalidBase64Hash))
			}
			return
		}

		// Begin a transaction with the vasco reader.
		let beginTransactionResult = beginTransaction()
		guard let _ = beginTransactionResult.error else {
			DispatchQueue.main.async {
				completionHandler(.failure(beginTransactionResult.error!))
			}
			return
		}

		// Set the security environment in order to verify and sign correctly.
		let setSecurityEnvironmentResult = setAuthenticationSecurityEnvironment()
		guard let _ = setSecurityEnvironmentResult.error else {
			DispatchQueue.main.async {
				completionHandler(.failure( setSecurityEnvironmentResult.error!))
			}
			return
		}

		// Verify that the users enters his pin correctly.
		let verifyPinResult = verifyPin()
		guard let _ = verifyPinResult.error else {
			DispatchQueue.main.async {
				completionHandler(.failure(verifyPinResult.error!))
			}
			return
		}

		// Perform the signature of the hash.
		let signResult = sign(data: data)
		DispatchQueue.main.async {
			completionHandler(signResult)
		}
	}
}

// MARK: - Throws
func beginTransactionThrows() throws -> Any {
	return ""
}

func setAuthenticationSecurityEnvironmentThrows() throws -> Any {
	return ""
}
func verifyPinThrows() throws -> Any {
	return ""
}

func signThrows(data: Data) throws -> Any {
	return data
}
func hash(documentHash: String) throws -> Data {
	guard let data = Data(base64Encoded: documentHash, options: .ignoreUnknownCharacters) else {
		throw ConnectiveError.invalidBase64Hash
	}
	return data
}

// SHORTER 1: IF YOU NEED TO DISPATCH TO MAIN

func authenticate2(documentHash: String, completionHandler: @escaping ( () throws -> Any ) -> Void) {
	connectiveQueue.async {

		do {
			// Check if the document hash is valid.
			let hash = try hash(documentHash)

			// Begin a transaction with the vasco reader.
			let _ = try beginTransactionThrows()

			// Set the security environment in order to verify and sign correctly.
			let _ = try  setAuthenticationSecurityEnvironmentThrows()

			// Verify that the users enters his pin correctly.
			let _ = try verifyPinThrows()

			// Perform the signature of the hash.
			DispatchQueue.main.async {
				completionHandler {try signThrows(data: hash)}
			}
		} catch {
			DispatchQueue.main.async {
				completionHandler { throw error}
			}
		}
	}
}

// SHORTER 2: IF THIS YOU DO NOT NEED TO GO TO MAIN

func authenticate3(documentHash: String, completionHandler: @escaping ( () throws -> Any )-> Void) {
	connectiveQueue.async {
		completionHandler {
			let hash = try hash(documentHash)
			let _ = try beginTransactionThrows()
			let _ = try  setAuthenticationSecurityEnvironmentThrows()
			let _ =  try verifyPinThrows()
			return try signThrows(data: hash)
		}
	}
}

// MARK: - Get the results 

authenticate(documentHash: "") { result in
	switch result {
	case .success(let result):
		print(result)
	case .failure(let error):
		print(error)
	}
}

authenticate2 (documentHash: "") { result in
	do {
		print(try result())
	} catch {
		print(error)
	}
}

authenticate3 (documentHash: "") { print(try? $0()) }

