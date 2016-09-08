public class Service {
    public let configuration: Configuration

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// You should override this and could use it like in `JSONService`
    public func serve<M: Mappable>(order: Order, result: (Result <M>) -> ()) {
        result(.Failure(Error.ShouldOverride))
    }

    public func checkStatusCodeAndData(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) throws -> NSData? {
        guard error == nil else {
            throw Error.Error(error)
        }

        guard let httpResponse = urlResponse as? NSHTTPURLResponse else {
            return data
        }

        let statusCode = httpResponse.statusCode
        guard statusCode != 404 else {
            throw Error.InvalidAuthentication
        }

        guard 200...201 ~= statusCode else {
            return data
        }

        guard let guardData = data else {
            return nil
        }
        return guardData
    }

}

