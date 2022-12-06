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

// MARK: синхронность и асинхронность на глобальных очередях

// Как только вы получили глобальную очередь например userQueue вы можете выполнять задания на ней либо синхронно используя метод sync либо асинхронно используя метод async
print("--------------------------------------")
print("               sync                   ")
print("Global .concurrent Q1 - .userInitiated")
print("--------------------------------------")
userQueue.sync { task("😀") }
task("😈")
sleep(2)

print("--------------------------------------")
print("               async                  ")
print("Global .concurrent Q1 - .userInitiated")
print("--------------------------------------")
userQueue.async { task("😀") }
task("😈")

// В случае синхронного выполнения все задания стартуют последовательно один за другим и следующее четко ждет завершения предыдущего. В качестве оптимизации функция sync может запустить замыкание на текущем потоке если это возможно и приоритет глобальной очереди не будет иметь значения. Именно это мы и видим.
// В слуае асинхронного выполнения задания task("😈") стартуют не дожидаясь завершения заданий task("😀") и приоритеть глобальной очереди userQueue выше приоритета выполнения кода на Playground. Следовательно задания на userQueue выполняются чаще.



 

