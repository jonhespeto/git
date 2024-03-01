
#  Дипломная работа по профессии «Системный администратор»

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).


### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![alt text](<Screenshot 2024-03-01 at 23.03.38.png>)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

![alt text](<Screenshot 2024-03-01 at 23.04.31.png>)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

![alt text](<Screenshot 2024-03-01 at 22.58.12.png>)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

![alt text](<Screenshot 2024-03-01 at 22.45.17.png>)

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

![alt text](<Screenshot 2024-03-01 at 22.47.06.png>)


### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 
![alt text](<Screenshot 2024-03-01 at 23.13.38.png>)
![alt text](<Screenshot 2024-03-01 at 23.15.10.png>)

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

![alt text](<Screenshot 2024-03-01 at 23.45.13.png>)
![alt text](<Screenshot 2024-03-01 at 23.44.24.png>)

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

![alt text](<Screenshot 2024-03-02 at 01.44.08.png>)

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

![alt text](<Screenshot 2024-03-02 at 01.44.08-1.png>)

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.
![alt text](<Screenshot 2024-03-01 at 23.11.10.png>)

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

![alt text](<Screenshot 2024-03-01 at 23.07.34.png>)
![alt text](<Screenshot 2024-03-01 at 23.08.22.png>)
![alt text](<Screenshot 2024-03-01 at 23.10.20.png>)
### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.
![alt text](<Screenshot 2024-03-01 at 23.27.06.png>)
![alt text](<Screenshot 2024-03-01 at 23.28.37.png>)