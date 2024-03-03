
#  Дипломная работа по профессии «Системный администратор»

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).


### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.
![alt text](<img/Screenshot 2024-03-03-19.png>)
![alt text](<img/Screenshot 2024-03-03-20.png>)
![alt text](<img/Screenshot 2024-03-03-21.png>)
![alt text](<img/Screenshot 2024-03-03-22.png>)
Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![Alt text](<img/Screenshot 2024-03-01-1.png>)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

![alt text](<img/Screenshot 2024-03-01-2.png>)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

![alt text](<img/Screenshot 2024-03-01-3.png>)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

![alt text](<img/Screenshot 2024-03-01-4.png>)

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

![alt text](<img/Screenshot 2024-03-01-5.png>)


### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 
![alt text](<img/Screenshot 2024-03-01-6.png>)
![alt text](<img/Screenshot 2024-03-01-7.png>)

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

![alt text](<img/Screenshot 2024-03-01-8.png>)
![alt text](<img/Screenshot 2024-03-01-9.png>)

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

![alt text](<img/Screenshot 2024-03-02-10.png>)

![alt text](<img/Screenshot 2024-03-02-18.png>)

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

![alt text](<img/Screenshot 2024-03-02-11.png>)

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.
![alt text](<img/Screenshot 2024-03-01-12.png>)

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

![alt text](<img/Screenshot 2024-03-01-13.png>)
![alt text](<img/Screenshot 2024-03-01-14.png>)
![alt text](<img/Screenshot 2024-03-01-15.png>)
### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.
![alt text](<img/Screenshot 2024-03-01-16.png>)
![alt text](<img/Screenshot 2024-03-01-17.png>)