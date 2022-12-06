import Foundation
import UIKit

let mainQueue = OperationQueue.main
let customQueue = OperationQueue()

mainQueue.addOperation {
    let label = UILabel()
    label.text = "Hello World!"
    label.font = .preferredFont(forTextStyle: .largeTitle)
}

let operation1 = Operation()
let fetchIdOperation = Operation()
let fetchUserPhotoWithIdOperation = Operation()

customQueue.maxConcurrentOperationCount = 1

fetchIdOperation.cancel()

fetchUserPhotoWithIdOperation.addDependency(fetchIdOperation)

mainQueue.addOperation(operation1)

customQueue.addOperation(fetchUserPhotoWithIdOperation)
