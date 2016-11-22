import Foundation

/// The perform methods are preferred but these methods are for convenience.
/// They do some default error handling.
extension Service {

    // MARK: - Results transformed to Model(s)

    // MARK: - Update

    /// Performs the call to the server. Provide a model
    /// - parameter call: where can the server be found?
    /// - parameter fail: if we cannot initialize the model this call will fail and print the failure.
    /// - parameter ok: returns initialized model
    open func performUpdate<ModelType: Deserializable & Updatable>(_ call: Call, on updateModel: ModelType, fail: @escaping (FaroError)->(), ok:@escaping (ModelType)->()) {

        perform(call, on: updateModel) { (result) in
            switch result {
            case .model(let model):
                guard let model = model else {
                    let faroError = FaroError.malformed(info: "UpdateModel \(updateModel) could not be updated. Maybe you did not implement update correctly failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(model)
            default:
                self.handle(result, and: fail)
            }
        }

    }

    // MARK: - Create

    // MARK: - Single model response

    /// Performs the call to the server. Provide a model
    /// - parameter call: where can the server be found?
    /// - parameter fail: if we cannot initialize the model this call will fail and print the failure.
    /// - parameter ok: returns initialized model
    open func performSingle<ModelType: Deserializable>(_ call: Call, fail: @escaping (FaroError)->(), ok:@escaping (ModelType)->()) {
        perform(call) { (result: Result<ModelType>) in
            switch result {
            case .model(let model):
                guard let model = model else {
                    let faroError = FaroError.malformed(info: "Model could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(model)
            default:
                self.handle(result, and: fail)
            }
        }
    }

    // MARK: - Collection model response

    /// Performs the call to the server. Provide a model
    /// - parameter call: where can the server be found?
    /// - parameter fail: if we cannot initialize the model this call will fail and print the failure.
    /// - parameter ok: returns initialized array of models
    open func performCollection<ModelType: Deserializable>(_ call: Call, fail: @escaping (FaroError)->(), ok:@escaping ([ModelType])->()) {
        perform(call) { (result: Result<ModelType>) in
            switch result {
            case .models(let models):
                guard let models = models else {
                    let faroError = FaroError.malformed(info: "Model could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(models)
            default:
                self.handle(result, and: fail)
            }
        }
    }

    // MARK: - With Paging information

    open func performSingle<ModelType: Deserializable, PagingType: Deserializable>(_ call: Call, page: @escaping(PagingType?)->(), fail: @escaping (FaroError)->(), ok:@escaping (ModelType)->()) {
        perform(call, page: page) { (result: Result<ModelType>) in
            switch result {
            case .model(let model):
                guard let model = model else {
                    let faroError = FaroError.malformed(info: "Model could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(model)
            default:
                self.handle(result, and: fail)
            }
        }
    }

    open func performCollection<ModelType: Deserializable, PagingType: Deserializable>(_ call: Call, page: @escaping(PagingType?)->(), fail: @escaping (FaroError)->(), ok:@escaping ([ModelType])->()) {
        perform(call, page: page) { (result: Result<ModelType>) in
            switch result {
            case .models(let models):
                guard let models = models else {
                    let faroError = FaroError.malformed(info: "Models could not be initialized. Maybe your init(from raw:) failed?")
                    self.print(faroError, and: fail)
                    return
                }
                ok(models)
            default:
                self.handle(result, and: fail)
            }
        }
    }

}
