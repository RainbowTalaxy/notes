# Combine 介绍

用苹果的话来说：
> “一个 随时间处理数据 的 声明式 的 Swift API。”

Combine 苹果采用的一种函数响应式编程的库，类似于 RxSwift 。Combine 使用了许多在其他语言和库中可以找到的相同的函数响应概念，并将Swift的静态类型特性应用到其解决方案中。

## 函数响应式编程 Functional reactive programming

函数响应式编程，也称为数据流编程，基于函数式编程编程的概念上。函数式编程应用于元素列表（元素的转变加工），而函数响应式应用于元素流（元素的转变加工、流的分割合并）

你可能想创建一个逻辑规则，来观察多个元素的变化、处理（可能会失败的）异步操作、随时间改变流的内容。处理事件流、时间、错误的发生，并协调系统如何去响应一个事件，是函数响应式编程的核心。

在编写用户界面的时候，函数响应式编程非常有用。或者更一般的，可以创建处理外部资源或者依赖于异步API的数据流管道。

## Combine 的特性

将这些概念应用到 Swift 中只是 Combine 所做的一部分。Combine 还通过加入 控流（back-pressure）的概念扩展了函数响应式编程。控流是指控制接收和处理的信息的数量。这使得 数据流可控可取消 的拓展概念得到更有效的实践。

Combine 被苹果其他的一些框架利用。SwiftUI是最受关注的例子，他包含了订阅者（subscriber）、发布者（publisher）这样的概念元素。Reality 也提供了用来响应事件的发布者。Foundation 里（比如 NotificationCenter、URLSession、Timer 等）也提供了一些附加功能。

## 什么时候使用 Combine

当您希望设置对各种输入做出反应的内容时，Combine 最适合。用户界面非常适合这种模式。

以下情况可以使用 Combine：
* 你可以对一个按钮进行设置，只有当输入的值是有效的，才可以使按钮可用
* 执行一些异步操作（比如检查网络服务），并利用返回值来更新内容
* 用来对用户在文本框中动态的输入作出反应，并根据用户输入的内容更新界面视图

Combine 并不局限于用户界面。任何异步操作序列都可以有效地作为流操作，特别是当每个步骤的结果流到下一个步骤时。比如，一系列网络服务请求，然后对结果进行解码。

Combine 还可以用于定义如何处理来自异步操作的错误。Combine通过设置流操作，并将它们合并在一起来实现这一点。苹果公司使用 Combine 的一个例子就有：当本地网络受到限制时，它可以从网络服务中获取低分辨率的图像。

使用 Combine 创建的许多流中只需要一些操作。即使只有几个操作，Combine 仍然可以更容易地查看和理解在编写管道时发生了什么。组合流操作是一种声明性方法，用于定义随着时间的推移应该对值流进行什么处理。

# 核心概念

只有几个概念需要理解，同时他们也是非常重要的：
* Publisher（发布者） 和 Subscriber（订阅者）
* Operators（操作者）
* Subjects （对象）

## 发布者和订阅者

一个发布者提供数据（当数据可用且获得请求）。一个发布者如果没有订阅，则不会发布任何数据。当你在描述一个发布者时，你会用两种相关类型（associatedtype）来表述他：Output 和 Failure 。比如发布者返回 String实例 ，并且可能以 URLError实例 的形式返回失败，那么发布者可以用 <String, URLError> 来描述。

订阅者负责（向发布者）请求数据和接收发布者提供的数据（或者失败信息）。订阅者用两种相关类型进行描述：Input 和 Failure 。订阅者发起数据请求，并空值接收到的数据量。在 Combine 中，他可以看作是“行为的驱动者”，没有了订阅者，其他的组成部分将闲置。

发布者和订阅者是相互连接的，并构成 Combine 的核心。当你连接一个订阅者到发布者上，Input 和 Output 类型必须一致，两者的 Failure 也需要一致。

操作者 -- 一个行为类似订阅者和发布者的对象。他既实现了 Publisher协议 ，又实现了 Subscriber协议 。他们支持订阅一个发布者，并接收订阅者的请求。

一般的数据流是这样处理的：  
发布者 -> 操作者1 -> 操作者2 -> ... -> 操作者n -> 订阅者

操作者可以被用来转换数值或者值的类型 -- Output 和 Failure 均可。操作者也可以分割、复制、合并数据流。操作者之间的 Output/Failure类型 必须一致，否则编译器会报错。

一个简单的数据流：
```swift
let _ = Just(5).map { 值 -> String in
    return "五"
}.sink { 接收的值 in
    print("最终结果接收到的值为 \(接收的值)")
}
```
1. 数据流从 发布者“Just”（Just 是 Combine框架 中的一种发布者，他的生命周期中只提供一次值，然后结束）开始，且他关联了一个数值5，且他的关联类型为 <Int, Never> 。
2. 数据流中有个 操作者“map” ，用来转换值和类型。在这个例子中，数值5 被转换为 "五" ，且将关联类型由 <Int, Never> 转换为 <String, Never> 。
3. 数据流以 订阅者“sink” 结束。

> 在 Xcode 中，如果流操作中的 Input 和 Output，或者 Failure 之间的类型不匹配，Xcode 可能会提供一个有用的修复。

在构建自己的数据流时，通常使用操作者来转换数据、类型来实现最终目标。最终目标可能是启用或者禁用UI界面元素，也可能是获取一些要现实的数据。许多 Combine框架 内置的操作者（比如上面的map）是专门帮助进行这些转换而创建的。

有许多的操作者以 try 作为前缀，表示他们将返回一个 <Error> 失败类型。例如 map 和 tryMap 。map 会将 Output 和 Failure 一同传输过去。而 tryMap 接受 Input、Output 和 Failure 类型，但总是输出一个 <Error> 失败类型。

你可以将发布者、操作者、订阅者看作是拥有两条类型流，一条是功能型（Input、Output）的，一条是错误型（Failure）的。

## 控流 Back Pressure

Combine 被设计来让订阅者控制数据流，因此能他能让订阅者控制数据流管道中发生的进程。控流是 Combine 中的一大特性

这意味着订阅者可以根据自己所需的信息量来驱动管道中的进程。当订阅者连接到发布者时，他会根据特定的需求（Demand）来请求数据。

请求会通过数据流管道向上传播。每个操作者一次接收数据的请求，并一次向其连接的发布者请求信息。

> 在早期版本中，订阅者请求数据的方式是异步的（asynchronous），但实践证明这样会丢失数据。因此后来的 Combine 中请求数据是同步或者阻塞（synchronous/blocking）的。

因为是订阅者在驱动数据流进程，这使得订阅者可以取消订阅，通过调用 Cancellable协议 中的 cancel()方法 。

> 订阅被取消的时候，将不能重新启动。开发者应当创建一个新的订阅，而不是重启一个已取消的订阅

## 生命周期

发布者-订阅者的生命周期如下：
1. 当一个订阅者附加到一个发布者时，发布者会调用 subscribe(_: Subscriber)
2. 订阅者会调用 receive(subscription: Subscription) 来接收发布者创建的订阅（subscription）
3. 发布者会调用 request(_: Demand) 来接收订阅者的需求信息（数据接收量等）
4. 订阅者会调用 receive(_: Input) 来接收来自发布者的数据，且数据符合第三步中的需求信息
5. 在订阅创建后，订阅者可以调用 cancel() 来取消订阅
6. 发布者可以选择发送 receive(completion:) 来进行订阅终止工作。这样的终止工作可能是正常的终止，也可能是以失败终止。

## 发布者 Publishers

发布者是数据的提供者。Publisher协议 严格要求发布者在订阅者请求数据的时候返回数据，并且以一个明确的完成情况来终止订阅。

Just 和 Future 是常见的发布者资源，你可以根据值或者异步函数来启动你的发布者。

当订阅者请求的时候，大部分的发布者会立即提供数据。在某些情况下，发布者可以使用单独的机制来返回数据。这是由 ConnectablePublisher协议 规定的（Publisher协议 继承了此协议）。符合 ConnectablePublisher协议 的发布者将会有个额外的机制：在订阅者提供请求后启动数据流。这可以是发布者本身单独的调用 connect() 。另一个选项是 autoconnect() ，他将在订阅者请求时立即启动数据流。

Combine 提供了许多便利的发布者：
* Just
* Future
* Deferred
* Empty
* Sequence
* Fail
* Record
* Share
* Multicast
* ObservableObject
* @Published

Combine 之外也有许多苹果的API提供发布者：
* SwiftUI中使用 @Published 和 @ObservedObject 属性包装器（由 Combine 提供），来创建一个发布者来支持他的声明式视图机制。
* Foundation
    - URLSession.dataTaskPublisher
    - KVO 实例中的 .publisher
    - NotificationCenter
    - Timer
    - Result

## 操作者 Operators

一些操作者支持将来自不同数据管道流的输出合并在一起、更改数据时间或过滤提供的数据。操作者还可能对他们将要操作的数据/错误类型进行约束限制。操作者开可以用于定义错误处理（error handling）、重试逻辑（retry logic）、缓冲（buffering）和预取（prefetch），以及支持调试。

Combine 中的操作者有：
* 映射 Mapping elements
    - scan
    - tryScan
    - setFailureType
    - map
    - tryMap
    - flatMap
* 过滤 Filtering elements
    - compactMap
    - tryCompactMap
    - replaceEmpty
    - filter
    - tryFilter
    - replaceError
    - removeDuplicates
    - tryRemoveDuplicates
* 减少 Reducing elements
    - collect
    - reduce
    - tryReduce
    - ignoreOutput
* 数学 Mathematic operations on elements
    - max
    - tryMax
    - count
    - min
    - tryMin
* 检验 Applying matching criteria to elements
    - allSatisfy
    - tryAllSatisfy
    - contains
    - containsWhere
    - tryContainsWhere
* 序列操作 Applying sequence operations to elements
    - firstWhere
    - tryFirstWhere
    - first
    - tryLastWhere
    - last
    - dropWhile
    - tryDropWhile
    - dropUntilOutput
    - prepend
    - drop
    - prefixUntilOutput
    - prefixWhile
    - tryPrefixWhile output
* 合并 Combining elements from multiple publishers
    - combineLatest
    - merge
    - zip
* 处理错误 Handling errors
    - catch
    - tryCatch
    - assertNoFailure
    - retry
    - mapError
* 类型管理 Adapting publisher types
    - switchToLatest
    - eraseToAnyPublisher
* 控制时间 Controlling timing
    - debounce
    - delay
    - measureInterval
    - throttle
    - timeout
* 编码 Encoding and decoding
    - encode
    - decode
* 处理多个订阅者 Working with multiple subscribers
    - multicast
* 调试 Debugging
    - breakpoint
    - handleEvents
    - print

## 对象 Subjects

对象是发布者的一种特殊情况（Subject协议 继承了 Publisher协议）。该协议要求实现 send(_:) ，来允许开发者向订阅者发送特定的值。

对象可以通过 send方法 ，来“注入”一个值到数据流中。

Combine 内置了两种对象：CurrentValueSubject 和 PassthroughSubject 。这两个对象比较相似，不同在于，CurrentValueSubject 需要一个初始的数值。

CurrentValueSubject 和 PassthroughSubject 为 实现了ObservableObject协议的对象 创建发布者提供了帮助。这个协议被SwiftUI中许多组件所支持。

## 订阅者 Subscriber

订阅者是接收数据的一方，在数据流管道的末端。

Combine 内置了两种订阅者：Assign 和 Sink 。SwiftUI 中还有一种订阅者：onReceive 。

订阅者支持取消订阅，并在发布者发布任何 Completion完成 之前关闭流处理。Assign 和 Sink 均实现了 Cancellable协议。

当你保留了一个订阅者的引用，你很有可能想要一个其订阅的引用来取消订阅。AnyCancellable类 提供了一个类型擦除的引用，来转换任何订阅者的类型到 AnyCancellable类。可以用这个引用的 cancel()方法来取消订阅，而不是去访问订阅本身。存储订阅者的引用很重要，因为当释放引用时，订阅者会取消自己的订阅。

Assign 将接收到的值应用（赋值）到一个对象的键路径（keypath）上。这是一个例子：
```swift
.assign(to: \.isEnabled, on: 登录按钮)
```

Sink 接受一个闭包，一个 处理接收到的值 的闭包。这允许开发者用自己的代码去终止一个数据流。
```swift
.sink { 接收的值 in
    print("最终接收到的值为 \(String(describing: 接收的值))")
}
```

> Sink 对编写单元测试也很有帮助。

其他的苹果API中也提供了订阅者。举个例子，SwiftUI 中几乎所有的控件都能表现得像订阅者一样。SwiftUI 中的 View协议 定义了一个 onReceive(publisher)方法 来将视图作为订阅者来使用。

在SwiftUI中，一个例子可能是这样的：
```swift
struct MyView : View {
    @State private var 当前状态值 = "ok"
    var body: some View {
        Text("当前状态: \(当前状态值)")
            .onReceive(我的订阅者) { 接收的值 in
                self.当前状态值 = 接收的值
            }
    }
}
```

> 可以利用 Assign 来更新控件的属性

# 利用 Combine 开发

一个常见的起手方式就是简单的将发布者、操作者、订阅者组合在一起，形成管道流。在本书后面的许多例子中会出现各种各样的设计模式，且多数例子为 为用户输入作出响应式反应 。

## 管道数据流的理性认识

有两种广泛的模式：
* 期望发布者返回一个数据然后立即完成
* 期望一个发布者能随时间推移返回许多数据

第一种可以称为“一次性”发布者，或者管道流。这些发布者被用来创建单个响应，然后立即终止。

而第二种是“持续性”发布者。这些发布者和相关管道流应当始终处于活动状态，并提供响应正在发生的事件的方法。这类管道流的寿命要长得多，通常不希望这样的管道失败或者终止。

如果你在使用 Combine 开发时，（你创建的）管道数据流们最好是以上中的一种，然后把他们编排在一起来达到你的目标。比如，“使用 flapMap 和 catch 来处理错误”这个例子（后文）明确的使用了“一次性”的管道流，来处理一个持续的管道流的错误。

当你创建发布者或管道的实例前，可以去思索他应当如何工作：是“一次性”的，还是“持续性”的？然后作出选择。这种选择可以通知你如何处理错误，或者你是否要处理控制事件发送的时间的操作者（比如 debounce 和 throttle ）。

除了数据的提供，你可能还需要思考管道流中的类型对（type pair）应当是啥。多数管道流都会有许多的数据转换，以及处理各种错误。

最终，使用 Combine 应当基于两端：
* 发布者（如何提供数据）
* 订阅者（如何处理数据）

## 发布者和订阅者的类型

先看个这个例子：
```swift
let x = PassthroughSubject<String, Never>()
    .flatMap { name in
        return Future<String, Error> { promise in
            promise(.success(""))
        }.catch { _ in
            Just("No user found")
        }.map { result in
            return "\(result) foo"
        }
    }
```

其中的 x 的类型为：
```swift
Publishers.FlatMap<Publishers.Map<Publishers.Catch<Future<String, Error>, Just<String>>, String>, PassthroughSubject<String, Never>>

// 或者这样看嵌套关系清楚一点
Publishers.FlatMap<
    Publishers.Map<
        Publishers.Catch<
            Future<String, Error>, 
            Just<String>
        >, 
        String
    >, 
    PassthroughSubject<String, Never>
>
```

我们会发现这样的类型十分复杂，如果你把这样的管道封装成API来用，不仅复杂而且可能毫无用处。当你想暴露对象（的类型）时，所有组合中的细节会让你分心，或者难以使用。

为了清理接口，并封装成良好的API，可以使用类型擦除来包装发布者或者订阅者。这么做可以明确地隐藏链式函数结构带来的类型复杂性。

两种分别用来简化发布者或订阅者类型的结构体：
* AnySubscriber
* AnyPublisher

每个发布者还继承了一个便利的方法 eraseToAnyPublisher() 来返回一个 AnyPublisher 实例。

我们对之前的例子使用类型擦除：
```swift
let x = PassthroughSubject<String, Never>()
    .flatMap { name in
        return Future<String, Error> { promise in
            promise(.success(""))
        }.catch { _ in
            Just("No user found")
        }.map { result in
            return "\(result) foo"
        }
    }.eraseToAnyPublisher()
```

x 的类型则为：
```swift
AnyPublisher<String, Never>
```

在闭包中构建小型管道流时，这样的方法也十分有用。后面会有相关例子。

## 管道数据流 和 线程

Combine 不是单线程结构。操作者（和发布者一样）可以在两个不同的派遣队列（dispatch queue）或者 runloops 。组合起来的管道流可以在单线程跑，也可以在多个队列或者线程中穿梭。

Combine 允许发布者明确调度者（scheduler），不管是接收上（管道）游还是发送下（管道）游的情况。这在一个更新UI的订阅者身上十分重要，因为UI的更新只能在主线程上完成。

举个例子，你可能在代码中见到这个操作者：
```swift
.receive(on: RunLoop.main)
```

许多操作符会影响线程或队列的使用。receive 和 subscribe 是两个常见的操作符。

许多其他的操作者会需要一个调度者作为参数。比如 delay、debounce、throttle 等。

> 如果想明确操作者或者后续的操作者在哪个线程运行，可以使用 receive操作者 定义。

## 在你的开发中利用 Combine

有两种常见的方法：
* 对与普通的操作者，简单利用闭包中的同步（阻塞）调用。最常见的有 map 和 tryMap
* 使用异步的，或者是提供补足回调的API，集成自己的代码。如果你集成的代码是异步的，那么你可能不会很轻松的在闭包中使用他。你需要将异步代码封装成一个能与 Combine操作者 一同使用和调用的结构。实际中，通常是创建一个返回发布者实例的调用，然后直接在管道流中调用。

Future 是专门用来集成异步代码的发布者。后面会有例子展示。
