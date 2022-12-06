import Foundation
import UIKit

// MARK: Практический пример
// Давайте создадим простую структуру для операций со всеми этими принципами. Операции имеют довольно много сложных понятий. Вместо создания примера, который слишком сложный, давайте просто напечатаем «Hello world» и попробуем включить большинство из них. Пример будет содержать асинхронное выполнение, зависимости и несколько операций, рассматриваемых, как одна. Давайте погрузимся в создание примера!


// MARK: - asyncOperation

// Сначала мы создадим Operation для создания асинхронных задач. Таким образом, мы можем создавать подклассы и любые асинхронные задачи.

class AsyncOperation: Operation {
    
    override var isAsynchronous: Bool {return true}
    
    var _isFinished: Bool = false
    
    override var isFinished: Bool {
        
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        
        get {return _isFinished}
    }
    
    var _isExecuting: Bool = false
    
    override var isExecuting: Bool {
        
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
        
        get {return _isExecuting}
    }
    
    func execute() {
    }
    
    override func start() {
        isExecuting = true
        execute()
        isExecuting = false
        isFinished = true
    }
}

// Это выглядит довольно некрасиво. Как видите, мы должны переопределить isFinished и isExecuting. Кроме того, изменения в них должны соответствовать требованиям KVO, в противном случае OperationQueue не сможет наблюдать за состоянием наших операций. В нашем методе start() мы управляем состоянием нашей операции от запуска выполнения до входа в состояние Finished(Завершено). Мы создали метод execute(). Это будет метод, который необходимо реализовать нашим подклассам.




// MARK: - TextOperation

class TextOperation: AsyncOperation {
    
    let text: String
    
    init(text: String) {self.text = text}
    
    override func execute() {print(text)}
}

// В этом случае нам просто нужно передать текст, который мы хотим распечатать в init(), и переопределить execute().




// MARK: - GroupOperation

// GroupOperation будет нашей реализацией для объединения нескольких операций в одну.

class GroupOperation: AsyncOperation {
    let queue = OperationQueue()
    var operations: [AsyncOperation] = []
    
    override func execute() {
        print("group started")
        queue.addOperations(operations, waitUntilFinished: true)
        print("group done")
    }
}

// Как видите, мы создаем массив, в котором наши подклассы будут добавлять свои операции. Затем во время выполнения мы просто добавляем операции в нашу приватную очередь. Таким образом мы гарантируем, что они будут выполнены в определенном порядке. Вызов метода addOperations ([Operation], waitUntilFinished: true) приводит к блокировке очереди до тех пор, пока не будут выполнены дополнительные операции. После этого GroupOperation изменит свое состояние на Finish.




// MARK: - Hello World Operation

// Просто создайте собственные операции, установите зависимости и добавьте их в массив. Вот и все.

class HelloWorldOperation: GroupOperation {
    
    override init() {
        super.init()
        
        let op1 = TextOperation(text: "Hello")
        let op2 = TextOperation(text: "World")
        
        op2.addDependency(op1)
        
        operations = [op2, op1]
    }
}




// MARK: - Operation Observer

// Итак, как мы узнаем, что операция завершена? Как один из способов, можно добавить competionBlock. Другой способ — зарегистрировать OperationObserver. Это класс, который подписывается на keyPath через KVO. Он наблюдает за всем, до тех пор, пока он совместим с KVO.

// Давайте в нашем маленьком Фреймворке напечатаем «done», как только закончится HelloWorldOperation:

class OperationObserver: NSObject {
    init(operation: AsyncOperation) {
        super.init()
        operation.addObserver(self, forKeyPath: "finished", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let key = keyPath else {return}
        
        switch key {
        case "finished": print("done")
        default: print("doing")
        }
    }
}




// MARK: - Передача Данных

// Для «Hello World!» не имеет смысла передавать данные, но давайте быстро рассмотрим этот случай. Самый простой способ — использовать BlockOperations. Используя их, мы можем установить свойства для следующей операции, которой необходимы данные. Не забудьте установить зависимость, иначе операция может не выполниться вовремя ;)

//let op1 = Operation1()
//let op2 = Operation2()
//
//let adapter = BlockOperation() { [unowned op1, unowned op2] in
//    op2.data = op1.data
//}
//
//adapter.addDependency(op1)
//op2.addDependency(adapter)
//
//queue.addOperations([op1, op2, adapter], waitUntilFinished: true)




// MARK: - Обработка Ошибок

// Еще одна вещь, которую мы не рассматриваем сейчас, — обработка ошибок. По правде говоря, я еще не нашел хороший способ сделать это. Один из вариантов заключается в том, Чтобы добавить вызов метода finished(withErrors:) и дать возможность каждой асинхронной операций вызывать его вместо AsyncOperation, обрабатывая его в start(). Таким образом, мы можем проверить наличие ошибок, и добавить их в массив. Допустим, у нас есть операция A, которая зависит от операции B. Внезапно операция B заканчивается ошибкой. И в этом случае Operation A может проверить этот массив и прервать его выполнение. В зависимости от требований, Вы можете добавить дополнительные ошибки.

// Это может выглядеть так:

class GroupOperation1: AsyncOperation {
    let queue = OperationQueue()
    var operations: [AsyncOperation] = []
    var errors: [Error] = []

    override func execute() {
        print("group started")
        queue.addOperations(operations, waitUntilFinished: true)
        print("group done")
    }

    func finish(withError errors: [Error]) {
        self.errors += errors
    }
}

// Имейте в виду, что подоперации должны соответствующим образом обрабатывать свое состояние, и для этого необходимо выполнить некоторые изменения в AsyncOperation.

// Но, как всегда, существует много способов, и это только один из них. Вы также можете использовать observer для наблюдения за значением ошибки.

// Неважно, как вы это делаете. Просто убедитесь, что ваша операция будет удаляться после завершения выполнения. Например: Если вы напишете в контексте CoreData, и что-то пойдет не так, вам необходимо очистить этот контекст. В противном случае у вас может быть неопределенное состояние.




// MARK: - UI Operations

// Операции не ограничиваются элементами, которые вы не видите. Все, что вы делаете в приложении, может быть операцией (хотя я бы советовал вам так не поступать). Но есть некоторые вещи, которые легче видеть как Операции. Все, что является модальным, следует учитывать соответствующим образом. Давайте посмотрим на операцию, чтобы отобразить диалог:

class UIOperation: AsyncOperation {
    let viewController = UIViewController()
    
    override func execute() {
        let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.handleInput()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func handleInput() {
        //do something and continue operation
    }
}
// Как видите, она приостанавливает свое выполнение, пока не будет нажата кнопка. После этого она войдет в свое законченное состояние, а затем все остальные операции, которые зависят от этой могут продолжаться.




// MARK: - Взаимное исключение

//Учитывая то, что мы можем использовать Operations для Пользовательского Интерфейса, появляется иная задача. Представьте, что вы видите диалог об ошибке. Возможно, вы добавляете в очередь несколько операций, которые будут отображать ошибку, когда сеть недоступна. Это легко может привести к тому, что при появлении предупреждений все вышеупомянутые Operations могут привести к разрыву сетевого подключения. В результате у нас было бы несколько диалогов, которые отобразились бы одновременно, и мы не знаем какой является первым, а какой вторым. Поэтому нам придется сделать эти диалоги взаимоисключающими.

// Несмотря на то, что сама идея сложная, ее довольно легко реализовать при помощи зависимостей. Просто создайте зависимость между этими диалогами, и все готово. Одной из проблем является отслеживание операции. Но это может быть разрешено с помощью операций именования, а затем наличием доступа к OperationQueue и поиска имени. Таким образом, вам не нужно держать ссылку.

let op1 = Operation()
op1.name = "Operation1"

OperationQueue.main.addOperations([op1], waitUntilFinished: false)
let operations = OperationQueue.main.operations

operations.map { op in
    if op.name == "Operation1" {
        op.cancel()
    }
}




// MARK: - Заключение

// Operations – это хороший инструмент для параллелизма. Но не обманывайте себя, они сложнее, чем вы думаете. В настоящее время я поддерживаю проект, базирующийся на Operations, а некоторые его части являются весьма сложными и неудобными в работе. В частности, при обработке ошибок появляется масса неисправностей. Каждый раз, когда вы выполняете групповую операцию, и она выполняется некорректно, существует вероятность более, чем одной ошибки. Вам придется отфильтровать их для получения необходимых ошибок определенного вида, поэтому иногда ошибка сбивает с толку из-за подпрограмм отображения.

// Другая проблема заключается в том, что вы перестаете думать о возможных параллельных идентичных проблемах. Я еще не говорил об этих деталях, но помню о GroupOperations с кодом обработки ошибок, приведенных выше. Они содержат ошибку, которая будет исправлена ​​в будущем посте.

// Operations — хороший инструмент для управления параллелизмом. GCD все еще не упорядочены. Для небольших задач, таких, как переключения потоков или задач, которые необходимо выполнить как можно быстрее, вы, возможно, не захотите использовать операции. Идеальным решением для этого является GCD.
