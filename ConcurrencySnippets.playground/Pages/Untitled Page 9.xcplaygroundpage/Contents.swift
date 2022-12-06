import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: Экспериментальная Среда

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


// MARK: private параллельные concurrent очереди

// Для того, чтобы инициализировать Private параллельную (.concurrent) очередь достаточно указать при инициализации Private очереди значение аргумента attributes равное .concurrent. Если вы не указываете этот аргумент, то Private очередь будет последовательной (.serial). Аргумент qos также не требуется и может быть пропущен без всяких проблем.

// Давайте назначим нашей параллельной очереди workerQueue качество обслуживания qos, равное .userInitiated, и поставим асинхронно в эту очередь сначала задания task("😀"), а потом task("😈")
 
// Наша новая параллельная очередь workerQueue действительно является параллельной, и задания в ней выполняются одновременно, хотя все, что мы сделали по сравнению со четвертым экспериментом (одна последовательная очередь serialPriorityQueue), это задали аргумент attributes равном .concurrent:

print("--------------------------------------")
print("Private .concurrent Q - .userInitiated")
print("--------------------------------------")

let workerQueue = DispatchQueue(label: "com.bescora.worker_concurrent", qos: .userInitiated, attributes: .concurrent)
workerQueue.async { task("😀") }
workerQueue.async { task("😈") }

sleep(2)

// Картина совершенно другая по сравнению с одной последовательной очередью. Если там все задания выполняются строго в том порядке, в котором они поступают на выполнение, то для нашей параллельной (многопоточной) очереди workerQueue, которая может «расщепляться» на несколько потоков, задания действительно выполняются параллельно: некоторые задания с символом "😈", будучи позже поставлены в очередь workerQueue, выполняются быстрее на параллельном потоке.

// Давайте используем параллельные Private очереди с разными приоритетами:

// очередь workerQueue1 c qos .userInitiated
// очередь workerQueue2 c qos .background

print("-------------------------------")
print(".concurrent Q1 - .userInitiated")
print(".concurrent Q1 - .background   ")
print("-------------------------------")

let workerQueue1 = DispatchQueue(label: "com.bestcora.worker_concurrent1", qos: .userInitiated, attributes: .concurrent)
let workerQueue2 = DispatchQueue(label: "com.bestcora.worker_concurrent2", qos: .background, attributes: .concurrent)

workerQueue2.async { task("😀") }
workerQueue1.async { task("😈") }

// Здесь такая же картина, как и с разными последовательными Private очередями во втором эксперименте. Мы видим, что задания чаще исполняются на очереди workerQueue1, имеющей более высокий приоритет.

// Можно создавать очереди с отложенным выполнением с помощью аргумента attributes, а затем активировать выполнение заданий на ней в любое подходящее время c помощью метода activate():

print("---------------------------------------------------------")
print("      параллельная очередь с отложенным выполнением      ")
print("Private .concurrent Q - .userInitiated, initiallyInactive")
print("---------------------------------------------------------")

let workerDelayQueue = DispatchQueue(label: "com.bescora.worker_concurrent", qos: .userInitiated, attributes: [.concurrent,.initiallyInactive])

workerDelayQueue.async { task("😀") }
workerDelayQueue.async { task("😈") }

print("-----------------------------------------")
print("выполнение заданий на паралельной очереди")
print("       с отложенным выполнением          ")
print("-----------------------------------------")

workerDelayQueue.activate()
