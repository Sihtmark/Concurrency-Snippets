import UIKit
import Foundation
import Dispatch

class AsyncOperarition: Operation {
    enum State {
        case isWaiting, isExecuting, isFinished
    }
    
    var state = State.isWaiting {
        willSet {
            switch(state, newValue) {
            case (.isWaiting, .isExecuting):
                willChangeValue(forKey: "isExecuting")
            case (.isWaiting, .isFinished):
                willChangeValue(forKey: "isFinished")
            case (.isExecuting, .isFinished):
                willChangeValue(forKey: "isExecuting")
                willChangeValue(forKey: "isFinished")
            default:
                fatalError("Invalid state change in AsyncOperation: \(state) to \(newValue)")
            }
        }
        didSet {
            switch(oldValue, state) {
            case (.isWaiting, .isExecuting):
                didChangeValue(forKey: "isExecuting")
            case (.isWaiting, .isFinished):
                didChangeValue(forKey: "isFinished")
            case (.isExecuting, .isFinished):
                didChangeValue(forKey: "isExecuting")
                didChangeValue(forKey: "isFinished")
            default:
                fatalError("Invalid state change in AsyncOperation: \(oldValue) to \(state)")
            }
        }
    }
    
    override var isExecuting: Bool {
        return state == .isExecuting
    }
    
    override var isFinished: Bool {
        return state == .isFinished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override init() {
        super.init()
        addObserver(self, forKeyPath: "isCancelled", options: [], context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "isCancelled")
    }
    
    override internal func observerValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, content: UnsafeMutablePointer<Void>) {
        guard keyPath == "isCancelled" else {
            return
        }
        if isCancelled {
            //???
        }
    }
    
    override func start() {
        guard NSThread.isMainThread() else {
            fatalError("AsyncOperation should only run on the main thread.")
        }
        
        guard !hasCancelledDependencies else {
            cancel()
            return
        }
        
        guard !isCancelled else {
            return
        }
        
        state = .isExecuting
        main()
    }
        // Where the main work of the operation happens. Subclasses can override this method to do their own work. If they do so, they must call finish() when the work is complete. Because this is an asynchronous operation, the actual call to finish() will usually happen in a delegate or completion block.
        override func main() {
            finish()
        }
        
        // Gets called whether the operation becomes cancelled (i.e. siCancelled becomes true). Subclasses can override this to cancel and tear down any work that's happening in main(). If they do so, they must call finish() when complete.
    func didCancel() {
        finish()
    }
    
    func finish() {
        state = .isFinished
    }
}

private extension AsyncOperarition {
    var hasCancelledDependencies: Bool {
        return dependencies.reduce(false) {$0 || $1.isCancelled}
    }
}
