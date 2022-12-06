import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


// MARK: Состояние гонки (Race Condition)
// Мы можем воспроизвести простейший случай race condition если будем изменять переменную value асинхронно на private очереди а показывать value на main потоке
var value = "😇"
var mySerialQueue = DispatchQueue.global(qos: .userInteractive)
func changeValue(variant: Int) {
    sleep(1)
    value += "🐔"
    print("\(value) - \(variant)")
}

// Запускаем changeValue() асинхронно и показываем value на main потоке
mySerialQueue.async {
    changeValue(variant: 1)
}
value // value не изменилось

// Теперь переустановим value а затем выполним changeValue() синхронно, блокируя текущий поток до тех пор пока задание changeValue не закончится убирая таким образом race condition
value = "🦊"
mySerialQueue.sync {
    changeValue(variant: 2)
}
value // value изменилось но неправильным образом

//MARK: Давайте заменим метод async на sync
// Запускаем changeValue() синхронно и показываем value на текущем потоке
print("Убираем Race Condition с помощью sync")
value = "😇"
mySerialQueue.sync {
    changeValue(variant: 1)
}
value // value изменилось

// Теперь переустановим value а затем выполним changeValue() тоже синхронно, блокируя текущий поток до тех пор пока задание changeValue() не закончится, убирая таким образом Race Condition
value = "🦊"
mySerialQueue.sync {
    changeValue(variant: 2)
}
value // value изменилось
