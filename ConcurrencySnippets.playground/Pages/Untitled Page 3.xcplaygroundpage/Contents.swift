//: [Previous](@previous)

import Foundation
import UIKit

let main = DispatchQueue.main

let userInteractiveQueue = DispatchQueue.global(qos: .userInteractive)
let userInitiatedQueue = DispatchQueue.global(qos: .userInitiated)
let defaultQueue = DispatchQueue.global(qos: .default)
let utilityQueue = DispatchQueue.global(qos: .utility)
let backgroundQueue = DispatchQueue.global(qos: .background)



//MARK: - Race Condition
var value = "💩"
let myserialQueue =  DispatchQueue.global(qos: .userInitiated) // в зависимости от приоритета будут меняться данные
func changeValue(variant: Int) {
    sleep(1)
    value = value + "🤟🏿"
    print("\(value) - \(variant)")
}

// Запускаем changeValue() асинхронно и показываем value на текущем потоке
myserialQueue.async {
    changeValue(variant: 1)
}
value

// теперь переустановим value, а затем выполним changeValue() СИНХРНОННО, блокируя текущий поток до тех пор, пока задание changeValue не закончится, убирая таким образом race condition
value = "🎃"
myserialQueue.sync {
    changeValue(variant: 2)
}
value


