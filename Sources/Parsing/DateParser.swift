import Foundation

class DateParser {
    internal static let shared = DateParser()
    internal let dateFormatter = DateFormatter()
    internal var dateFormat: String {
        get {
            return dateFormatter.dateFormat
        } set {
            if dateFormatter.dateFormat != newValue {
                dateFormatter.dateFormat = newValue
            }
        }
    }
}
