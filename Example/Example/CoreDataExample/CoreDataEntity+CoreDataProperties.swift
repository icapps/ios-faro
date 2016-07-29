

import Foundation
import CoreData
import Faro

extension CoreDataEntity: UniqueAble {

    @NSManaged var uniqueValue: String?
	@NSManaged var username: String?
}
