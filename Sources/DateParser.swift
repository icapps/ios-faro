import Foundation

class DateParser {
    static let shared = DateParser()
    let dateFormatter = DateFormatter()
    var dateFormat: String {
        get {
            return dateFormatter.dateFormat
        } set {
            if dateFormatter.dateFormat != newValue {
                dateFormatter.dateFormat = newValue
            }
        }
    }
}

public func setDateFormat(_ format: String) {
    DateParser.shared.dateFormat = format
}
