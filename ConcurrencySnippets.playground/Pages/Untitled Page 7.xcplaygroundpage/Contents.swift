import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: Экспериментальная Среда

// MARK: Глобальные Очереди и Задания

// Определяем бесконечное выполнение чтобы предотвратить выбрасывания background tasks когда main thread будет закончена

// Использование global queues

// 1. Глобальная последовательная (serial) main queue
let mainQueue = DispatchQueue.main

// 2. Глобальные Concurrent dispatch queues
let userInteractiveQueue = DispatchQueue.global(qos: .userInteractive)
let userQueue = DispatchQueue.global(qos: .userInitiated)
let defaultQueue = DispatchQueue.global()
let utilityQueue = DispatchQueue.global(qos: .utility)
let backgroundQueue = DispatchQueue.global(qos: .background)

// В качестве задания task выберем печать любых одинаковых символов и приоритета текущей очереди. Еще одно задание taskHIGH которое будет печатать один символ мы будем запускать с высоким приоритетом:

// tasks:
func task(_ symbol: String) {
    for i in 1...10 {
        print("\(symbol) \(i) prioritate = \(qos_class_self().rawValue)")
    }
}
func taskHIGH(_ symbol: String) {
    print("\(symbol) prioritate = \(qos_class_self().rawValue)")
}


// MARK: Private последовательные очереди

// Помимо глобальных очередей можно создавать пользовательские private очереди с помощью инициализатора класса DispatchQueue

// Единственное что необходимо указать при создании пользовательской очереди - это уникальная метка label. Если не создавать больше никаких других аргументов кроме label то по умолчанию создается последовательная (.serial) очередь. Есть и другие аргументы которые можно создать при инициализации очереди

// Смотрим как работает Private последовательная очередь mySerialQueue при использовании sync и async методов:

// Private Serial Queue
let mySerialQueue = DispatchQueue(label: "com.bescora.mySerial")

print("-----------------------")
print("         sync          ")
print("Private .serial Q1 - no")
print("-----------------------")

mySerialQueue.sync { task("😀") }
task("😈")

print("-----------------------")
print("         async         ")
print("Private .serial Q1 - no")
print("-----------------------")

mySerialQueue.async { task("😀") }
task("😈")

/// В случае синхронного sync мы видим ту же ситуацию, что и в эксперименте 3 -тип очереди не имеет значения, потому что в качестве оптимизации функция sync может запустить замыкание на текущем потоке. Именно это мы и видим.

/// Что произойдет, если мы используем async метод и позволим последовательной очереди mySerialQueue выполнить задания
 
/// асинхронно по отношению к текущей очереди? В этом случае выполнение программы не останавливается и не ожидает, пока завершится это задание в очереди mySerialQueue; управление немедленно перейдет к выполнению заданий

/// и будет исполнять их в одно и то же время, что и задания
