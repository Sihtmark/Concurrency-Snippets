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


// MARK: приоритеты QOS последовательных очередей

// Давайте назначим нашей Private последовательной очереди serialPriorityQueue качество обслуживания qos, равное .userInitiated, и поставим асинхронно в эту очередь сначала задания а потом этот эксперимент убедит нас в том, что наша новая очередь serialPriorityQueue действительно является последовательной, и несмотря на использование async метода, задания выполняются последовательно друг за другом в порядке поступления:

print("-----------------------------------")
print("Private .serial Q1 - .userInitiated")
print("-----------------------------------")

let serialPriorityQueue = DispatchQueue(label: "com.bestcora.serialPriority", qos: .userInitiated)

serialPriorityQueue.async { task("😀") }
serialPriorityQueue.async { task("😈") }

sleep(1)

// Таким образом, для многопоточного выполнения кода недостаточно использовать метод async, нужно иметь много потоков либо за счет разных очередей, либо за счет того, что сама очередь является параллельной (.concurrent). Ниже в эксперименте 5 с параллельными (.concurrent) очередями мы увидим аналогичный эксперимент с Private параллельной (.concurrent) очередью workerQueue, но там будет совсем другая картина, когда мы будем помещать в эту очередь те же самые задания.

// Давайте используем последовательные Private очереди с разными приоритетами для асинхронной постановки в эту очереди сначала заданий task("😀"), а потом заданий task("😈")

// очередь serialPriorityQueue1 c qos .userInitiated

// очередь serialPriorityQueue2 c qos .background

print("-----------------------------------")
print("Private .serial Q1 - .userInitiated")
print("  Private .serial Q1 - .background ")
print("-----------------------------------")

let serialPriorityQueue1 = DispatchQueue(label: "com.bestcora.serialPriority", qos: .userInitiated)
let serialPriorityQueue2 = DispatchQueue(label: "com.bestcora.serialPriority", qos: .background)

serialPriorityQueue2.async { task("😀") }
serialPriorityQueue1.async { task("😈") }

sleep(1)

// Здесь происходит многопоточное выполнение заданий, и задания чаще исполняются на очереди serialPriorityQueue1, имеющей более приоритетное качество обслуживания qos: .userIniatated.

// Вы можете задержать выполнение заданий на любой очереди DispatchQueue на заданное время, например, на now() + 0.1 с помощью функции asyncAfter и еще изменить при этом качество обслуживания qos:

print("--------------------------------")
print("asyncAfter (.userInteractive) Q2")
print("  Private .serial Q1 - .utility ")
print("Private .serial Q1 - .background")
print("--------------------------------")

let serialUtilityQueue = DispatchQueue(label: "com.bestcora.serialUtilityPriority", qos: .utility)
let serialBackgroundQueue = DispatchQueue(label: "com.bestcora.serialBackgroundPriority", qos: .background)

serialBackgroundQueue.asyncAfter(deadline: .now() + 0.1, qos: .userInteractive) { task("😀") }
serialUtilityQueue.async { task("😈") }

sleep(1)
