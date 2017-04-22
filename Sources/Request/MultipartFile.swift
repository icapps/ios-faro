import Foundation

open class MultipartFile {
    
    let parameterName: String
    let data: Data
    let mimeType: MultipartMimeType
    
    /// Initializes MultipartFile to send to the server.
    /// parameter parameterName: the name of the multipart file parameter as defined on the server.
    /// parameter data: the file or image as Data. (e.g. a UIImage converted to Data using UIImageJPEGRepresentation())
    /// parameter mimeType: the correct mime type for the file.
    public required init(parameterName: String, data: Data, mimeType: MultipartMimeType) {
        self.parameterName = parameterName
        self.data = data
        self.mimeType = mimeType
    }
}

public enum MultipartMimeType: String {
    // Supported image types
    case jpeg = "image/jpg"
    case png = "image/png"
    // Supported text types
    case plain = "text/plain"
}
