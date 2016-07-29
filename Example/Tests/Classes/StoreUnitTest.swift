import Foundation
import Faro

/**
Every unit test class should have its own managedObjectContext.
Look at CoreDataEntitySpec for an example.
*/

class StoreUnitTests: CoreDataUnitTest {

	init(){
		super.init(modelName:"Model")
	}
}