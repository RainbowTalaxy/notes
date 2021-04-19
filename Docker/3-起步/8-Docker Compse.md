# 使用 Docker Compose

[原页面](https://docs.docker.com/get-started/08_using_compose/)

Docker Compose 是一款旨在帮助定义和共享多容器应用程序的工具。使用Compose，我们可以创建一个 YAML 文件来定义服务，然后使用一个命令将所有内容运转起来或将其分解。

使用 Compose 的最大好处是，你可以在文件中定义应用程序堆栈，将其保留在项目仓库的根目录（现在由版本控制）中，并轻松地使其他人为您的项目做出贡献。只需复制您的存储库并启动撰写应用即可。实际上，您可能会在 GitHub/GitLab 上看到很多项目正在执行此操作。

## 安装 Docker Compose
如果是安装了 Docker Desktop/Toolbox 在 Windows 或 Mac 上，则你已经拥有 Docker Compose 了。如果是 Linux ，则需要手动安装（[教程](https://docs.docker.com/compose/install/)）。

安装之后，可以看一下是否能运行。
```shell
docker-compose version
```

## 创建 Compose 文件
1. 在应用项目的根目录下，创建一个名为 `docker-compose.yml` 的文件。
2. 在组合文件中，首先定义架构版本。多数情况下，最好使用最新的支持版本。你可以在 [Compose 文件参考](https://docs.docker.com/compose/compose-file/) 查看现存版本和兼容性列表。
    ```yml
    version: "3.7"
    ```
3. 接着，定义一系列的服务（或者叫容器）来运行我们的应用。
    ```yml
    version: "3.7"
    services:
    ```

## 定义应用服务
这是我们用来定义我们应用容器的命令。
```shell
docker run -dp 3000:3000 \
  -w /app -v "$(pwd):/app" \
  --network todo-app \
  -e MYSQL_HOST=mysql \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=todos \
  node:12-alpine \
  sh -c "yarn install && yarn run dev"
```

1. 首先为容器定义服务的入口和镜像。我们可以给服务起任何名字。名字会自动成为一个网络别名，这将对定义 MySQL 服务非常有用。
    ```yml
    version: "3.7"

    services:
    app:
        image: node:12-alpine
    ```
2. 你会看到命令紧跟着 `image` 定义，但这两者顺序是可以变化的。
    ```yml
    version: "3.7"

    services:
      app:
        image: node:12-alpine
        command: sh -c "yarn install && yarn run dev"
    ```
3. 接着定义 `ports` ，我们将使用[短语法](https://github.com/compose-spec/compose-spec/blob/master/spec.md#short-syntax)，但也可以用[长语法](https://github.com/compose-spec/compose-spec/blob/master/spec.md#long-syntax)。
    ```yml
    version: "3.7"

    services:
      app:
        image: node:12-alpine
        command: sh -c "yarn install && yarn run dev"
        ports:
          - 3000:3000
    ```
4. 继续，我们通过 `working_dir` 和 `volumes` 来定义工作目录（`-w /app`）和挂载卷映射（`-v "$(pwd):/app"`）。挂载卷也有长短语法。

    使用 Docker Compose 挂载卷定义的一个好处是，我们可以使用相对路径（当前目录）。
    ```yml
    version: "3.7"

    services:
      app:
        image: node:12-alpine
        command: sh -c "yarn install && yarn run dev"
        ports:
          - 3000:3000
        working_dir: /app
        volumes:
          - ./:/app
    ```
5. 最后，我们通过 `environment` 定义环境变量。
    ```yml
    version: "3.7"

    services:
      app:
        image: node:12-alpine
        command: sh -c "yarn install && yarn run dev"
        ports:
          - 3000:3000
        working_dir: /app
        volumes:
          - ./:/app
        environment:
          MYSQL_HOST: mysql
          MYSQL_USER: root
          MYSQL_PASSWORD: secret
          MYSQL_DB: todos
    ```

## 定义 MySQL 服务
容器命令为：
```shell
docker run -d \
  --network todo-app --network-alias mysql \
  -v todo-mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=todos \
  mysql:5.7
```
1. 首先定义一个新的服务叫做 mysql ，这将作为网络别名。
    ```yml
    version: "3.7"

    services:
      app:
        # The app service definition
      mysql:
        image: mysql:5.7
    ```
2. 接着，定义挂载卷映射。当我们使用 `docker run` 运行容器时，命名挂载卷会自动创建。但是，Compose 不会自动创建。我们需要在顶级 `volumes:` 中定义挂载卷，并明确其在服务配置中的挂载点。这里可以仅提供挂载卷名字，来使用默认选项。还有[更多的选项](https://github.com/compose-spec/compose-spec/blob/master/spec.md#volumes-top-level-element)可以使用。
    ```yml
    version: "3.7"

    services:
      app:
        # The app service definition
      mysql:
        image: mysql:5.7
        volumes:
          - todo-mysql-data:/var/lib/mysql
        
    volumes:
      todo-mysql-data:
    ```
3. 最后是环境变量。
    ```yml
    version: "3.7"

    services:
      app:
        # The app service definition
      mysql:
        image: mysql:5.7
        volumes:
          - todo-mysql-data:/var/lib/mysql
        environment: 
          MYSQL_ROOT_PASSWORD: secret
          MYSQL_DATABASE: todos
        
    volumes:
      todo-mysql-data:
    ```
最后，`docker-compose.yml` 应当是这样的：
```yml
version: "3.7"

services:
  app:
    image: node:12-alpine
    command: sh -c "yarn install && yarn run dev"
    ports:
      - 3000:3000
    working_dir: /app
    volumes:
      - ./:/app
    environment:
      MYSQL_HOST: mysql
      MYSQL_USER: root
      MYSQL_PASSWORD: secret
      MYSQL_DB: todos

  mysql:
    image: mysql:5.7
    volumes:
      - todo-mysql-data:/var/lib/mysql
    environment: 
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: todos

volumes:
  todo-mysql-data:
```

## 运行我们的应用栈
1. 确保没有应用或数据库正在运行（`docker ps` 和 `docker rm -f <ids>`）。
2. 使用 `docker-compose up` 启动应用栈。我们使用 `-d` 来后台运行应用。
    ```shell
    docker-compose up -d
    ```
    运行后输出应当是这样的：
    ```
    Creating network "app_default" with the default driver
    Creating volume "app_todo-mysql-data" with default driver
    Creating app_app_1   ... done
    Creating app_mysql_1 ... done
    ```
    可以看到网络和挂载卷都创建了。默认情况下，Docker Compose 会自动为应用栈创建一个网络。
3. 可以用 `docker-compose logs -f` 查看日志。你可以看到每个服务的日志形成一个流。这可以帮助你查看事件相关的问题。使用 `-f` 修饰符来实时展示日志。

    日志大概长这样...
    ```
    mysql_1  | 2019-10-03T03:07:16.083639Z 0 [Note] mysqld: ready for connections.
    mysql_1  | Version: '5.7.27'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)
    app_1    | Connected to mysql db at host mysql
    app_1    | Listening on port 3000
    ```
    如果想查看某个具体服务的日志，可以加上服务的名称，比如 `docker-compose logs -f app` 。

> 当应用启动时，实际上他会等待 MySQL 服务上线并尝试连接。Docker 没有任何内置支持来等待另一个容器完全启动，运行并准备就绪，然后再启动另一个容器。对于基于 Node 的项目，你可以使用 [wait-port](https://github.com/dwmkerr/wait-port) 依赖。别的语言可能有类似的框架。

## 在 Dashboard 中查看应用栈
在 Docker Dashboard 中，可以看到有个组叫 **app** 。这就是由 Docker Compose 创建的项目名。默认情况下，项目名就是 `docker-compose.yml` 所在目录的名字。

打开这个组，可以看到定义了两个容器。同时这两个容器的名字是描述性的，遵循 `<project-name>_<service-name>_<replica-number>` 的模板。

## 终止应用栈
可以用 `docker-compose down` 终止整个应用栈，或者点击 Docker Dashboard 中的垃圾桶。

> 默认情况下，挂载卷是不会随之移除的。可以添加 `--volumes` 来移除挂载卷。

> 同样的，Docker Dashboard 也不会移除挂载卷。
