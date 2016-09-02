
public class Service {
    let configuration : Configuration

    public init (configuration : Configuration) {
        self.configuration = configuration
    }
    
    /// You should override this and could use it like in `JSONService`
    public func serve <M : Mappable> (order: Order, result: (Result <M>)->()) {
        result(.Failure(Error.ShouldOverride))
    }

    public func checkStatusCodeAndData(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) throws -> NSData? {
        guard error == nil else {
           throw Error.Error(error)
           return nil
        }

        if let httpResponse = urlResponse as? NSHTTPURLResponse {

            let statusCode = httpResponse.statusCode

            guard statusCode != 404 else {
                throw Error.InvalidAuthentication
                return nil
            }

            guard 200...201 ~= statusCode else {
                return data
            }

            guard let data = data else {
                return nil
            }

            return data
        }
        else {
            return data
        }
    }
}

///Catches any throws and switches if to af failure after printing the error.
public func catchThrows  <M : Mappable> (result: (Result<M>) -> (), thrower: ()throws -> ())  {
    do {
        try thrower()
    }catch Error.Error(let nserror){
        print("💣 Error from service: \(nserror)")
        result(.Failure(Error.Error(nserror)))
    }catch Error.General{
        print("💣 General service error")
        result(.Failure(Error.General))
    }catch Error.InvalidResponseData(let data){
        print("🤔 Invalid response data")
        result(.Failure(Error.InvalidResponseData(data)))
    }catch Error.InvalidAuthentication{
        print("🤔 Invalid response data")
        result(.Failure(Error.InvalidAuthentication))
    }catch {
        print("💣 failed with unknown error \(error)")
        result(.Failure(error))
    }
}