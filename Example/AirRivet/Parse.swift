
import AirRivet

/**
This is an example implementation of the protocol `Environment`. 
*/
public class Parse <Rivet: EnvironmentConfigurable>: Environment, Mockable, Transformable {
	public var serverUrl = "https://api.parse.com/1/classes/"
	public var request: NSMutableURLRequest {
		let URL = NSURL(string: "\(serverUrl)\(Rivet().contextPath())")
		let request = NSMutableURLRequest(URL: URL!)

		// Headers

		request.addValue("oze24xbiOCeIdsM11C6MXK2RMLunOmoAWQ5VB6XZ", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("Bd99hIeNb8sa0ZBIVLYWy9wpCz4Hb5Kvri3NiqBu", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		return request
	}

	public func shouldMock() -> Bool {
		return false
	}
}