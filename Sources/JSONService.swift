
/// Default implementation of a JSON service.
/// Serves your `Order` to a server and parses the respons.
/// Response is delivered to you as a `JSONResult`.
public class JSONService : Service {
    private var task: NSURLSessionDataTask?

    /// Always results in .Success(["key" : "value"])
    /// This will change to a real request in the future
    override public func serve <M : Mappable> (order: Order, result: (Result<M>) -> ()) {
        guard let url = configuration.url else {
            result(.Failure)
            return
        }

        let fullUrl = url.URLByAppendingPathComponent(order.path)
        let mutableRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
         mutableRequest.HTTPMethod = order.method.rawValue

        let session = NSURLSession.sharedSession()
        task = session.dataTaskWithURL(fullUrl, completionHandler: { [weak self] (data, response, error) in
            if let data = self?.checkStatusCodeAndData(data, urlResponse: response, error: error) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    result(.JSON(json))
                }catch {
                    result(.Failure)
                }
            }else {
                result(.Failure)
            }
        })

        task?.resume()
    }

    public func cancel() {
        task?.cancel()
    }

    public func checkStatusCodeAndData(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) -> NSData? {

        guard error == nil else {
            //TODO: handle error cases
            return nil
        }

        if let httpResponse = urlResponse as? NSHTTPURLResponse {

            let statusCode = httpResponse.statusCode

            guard statusCode != 404 else {
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