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


// MARK: Использование DispatchWorkItem объектов

// Если вы хотите иметь дополнительные возможности по управлению выполнением различных заданий на Dispatch очередях то можно создать DispatchWorkItem для которого можно задать качество обслуживания qos и оно будет воздействовать на его выполнение

// highPriorityItem = DispatchWorkItem

var highPriorityItem = DispatchWorkItem(qos: .userInteractive, flags: .enforceQoS){
    taskHIGH("🌹")
}

// задавая флаг [.enforceQos] при подготовке DispatchWorkItem, мы получаем более высокий приоритет для задания highPriorityItem перед остальными заданиями на той же очереди:

print("-------------------------------")
print(".concurrent Q1 - .userInitiated")
print(".concurrent Q1 - .background   ")
print("-------------------------------")

let workerQueue1 = DispatchQueue(label: "com.bestcora.concurrent2", qos: .userInitiated, attributes: .concurrent)
let workerQueue2 = DispatchQueue(label: "com.bestcora.concurrent3", qos: .background, attributes: .concurrent)

workerQueue1.async { task("😀") }
workerQueue2.async { task("😈") }

workerQueue2.async(execute: highPriorityItem)
workerQueue1.async(execute: highPriorityItem)

// Это позволяет принудительно повышать приоритет выполнения конкретного задания на Dispatch Queue с определенным качеством обслуживания qos и таким образом бороться с явлением "инверсия приоритетов". Мы выдим что не смотря на то что два задания highPriorityItem стартуют самыми последними они выполняются в самом начале благодаря флагу [.enforceQos] и повышению приоритета до .userInteractive. Кроме того задание highPriorityItem может запускаться многократно на различных очередях.

// Если мы уберем флаг [.enforceQos]:
// highPriorityItem = DispatchWorkItem(qos: .userInteractive) { taskHIGH("🌹") }
// то задания highPriorityItem будут брать то качество обслуживания qos которое установлено для очереди на которой они запускаются. Но все равно они попадают в самое начало соответствующих очередей.



