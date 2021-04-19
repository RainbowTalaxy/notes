# http.ClientRequest
这类对象由内部创建从 http.request() 返回。它代表一个进行中的请求。请求头是可变的，可以用 setHeader(name, value) ，getHeader(name) ，removeHeader(name) 。当第一份数据块被发送或者 request.end() 被调用的时候，实际的请求头才会被发送。

为了获得响应，可以给该对象添加一个 'reponse' 监听器，当响应头被接收的时候 'reponse' 事件会被触发。'response' 事件需要一个参数，类型为 http.IncomingMessage 。

在 'response' 事件中，可以添加别的监听器：尤其是 'data' 事件。

如果没有 'response' 事件，响应则会被抛弃。但如果有 'response' 事件，那么响应对象中的的数据必须被消耗。不管是用 response.read() 还是监听 'readable' 事件，或者添加一个 'data' 处理，或者调用 .resume() 方法。'end' 事件不会被触发直到数据被消耗。同时，只有消耗了数据才不会引发超出内存的错误。

和 request 对象不一样，如果响应提前关闭，response 并不会触发 'error' 事件，但是会触发 'aborted' 事件。

Node.js 不会检查 Content-Length 和传输的 body 长度是否一致。