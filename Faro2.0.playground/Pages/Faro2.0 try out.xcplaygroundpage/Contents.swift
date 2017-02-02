import Foundation

protocol Deserializable {
	init(_ raw:[String: Any])
}

class Food: Deserializable {

	required init(_ raw: [String : Any]) {
		// parsing
	}
}

enum Result<T> {
	case success(T)
	case fail(ServiceError)
}
enum ServiceError: Error {
	case fail(String)
}

class Service<T: Deserializable> {

	func singleEnum(complete: @escaping(Result<T>) -> Void) {
		DispatchQueue(label: "success background").async {
			complete (.success(T(["":""])))
		}
	}

	func collectionEnum(complete: @escaping ((Result<[T]>) -> Void))  {
		DispatchQueue(label: "success background").async {
			complete (.success([T(["":""])]))
		}
	}

	func single(complete: @escaping(() throws -> (T)) -> Void) {
		DispatchQueue(label: "success background").async {
			complete {T(["":""])}
		}
	}

	func collection(complete: @escaping (() throws -> [T]) -> Void)  {
		DispatchQueue(label: "success background").async {
			complete{[T(["":""])]}
		}
	}
}

class FailService<T: Deserializable>: Service<T> {

	override func singleEnum(complete: @escaping(Result<T>) -> Void) {
		DispatchQueue(label: "success background").async {
			complete (.fail(ServiceError.fail("Single enum wrong")))
		}
	}

	override func collectionEnum(complete: @escaping ((Result<[T]>) -> Void))  {
		DispatchQueue(label: "success background").async {
			complete (.fail(ServiceError.fail("Collection enum wrong")))
		}
	}

	override func single(complete: @escaping (() throws -> (T)) -> Void) {
		DispatchQueue(label: "fail background").async {
			complete {throw ServiceError.fail("throw single wrong")}
		}
	}

	override func collection(complete: @escaping(() throws -> [T]) -> Void)  {
		DispatchQueue(label: "fail background").async {
			complete {throw ServiceError.fail("throw collection wrong")}
		}
	}
}

let service = Service<Food>()

service.single {print((try? $0()) ?? "single went wrong")}
service.singleEnum {print($0)}
service.collection {print((try? $0()) ?? "collection went wrong")}
service.collectionEnum {print($0)}

service.single {
	do {
		print(try $0())
	} catch {
		print(error)
	}
}

service.singleEnum { (result) in
	switch result {
	case .success(let food):
		print(food)
	case .fail(let error):
		print(error)
	}
}

service.collection {
	do {
		print(try $0())
	} catch {
		print(error)
	}
}

service.collectionEnum { (result) in
	switch result {
	case .success(let food):
		print(food)
	case .fail(let error):
		print(error)
	}
}

let failingService = FailService<Food>()

failingService.single {print((try? $0()) ?? "single went wrong")}
failingService.singleEnum {print($0)}
failingService.collection {print((try? $0()) ?? "collection went wrong")}
failingService.collectionEnum {print($0)}


failingService.single {
	do {
		print(try $0())
	} catch {
		print(error)
	}
}

failingService.singleEnum { (result) in
	switch result {
	case .success(let food):
		print(food)
	case .fail(let error):
		print(error)
	}
}

failingService.collection {
	do {
		print(try $0())
	} catch {
		print(error)
	}
}

failingService.collectionEnum { (result) in
	switch result {
	case .success(let food):
		print(food)
	case .fail(let error):
		print(error)
	}
}