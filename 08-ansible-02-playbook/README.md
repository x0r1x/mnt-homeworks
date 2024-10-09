# Домашнее задание к занятию 2 «Работа с Playbook»

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook). Так же приложите скриншоты выполнения заданий №5-8
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

#### Решение

1. Структура проекта который получился, я разделил на 3 роли:
    * `debian` установка доп пакетов
    * `clickhouse` установка и запуск clickhouse
    * `vector` установка и запуск vector

    Vector, устанавливается через репозитории, через template и jinja формируется два шаблона которые заливаются на сервер `clickhouse`:
    * Шаблон `vector.config.j2` конфига `vector.yaml`
    * Шаблон `vector.service.j2` конфига запуска как сервиса `vector.serice`


```bash
.
├── group_vars
│   └── clickhouse
│       └── vars.yml
├── inventory
│   └── prod.yml
├── roles
│   ├── clickhouse <-- Установка и запуск Clickhouse
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   └── main.yaml
│   │   └── vars
│   │       └── main.yml
│   ├── debian <-- Установка доп пакетов
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── vars
│   │       └── main.yml
│   └── vector <-- Установка и запуск Vector
│       ├── handlers
│       │   └── main.yml
│       ├── tasks
│       │   └── main.yml
│       ├── templates
│       │   ├── vector.config.j2
│       │   └── vector.service.j2
│       └── vars
│           └── main.yml
└── site.yml <-- Основной playbook

17 directories, 13 files
```

2. Детальный лог запуска [run_playbook](run_playbook.log)

3. Проверяем на ошибки, получаем громадный пулл замечаний

```bash
alekseykashin@MBP-Aleksej playbook % ansible-lint site.yml
WARNING  Listing 49 violation(s) that are fatal
yaml[new-line-at-end-of-file]: No new line character at the end of file
roles/clickhouse/handlers/main.yml:6

fqcn[action-core]: Use FQCN for builtin module actions (apt_repository).
roles/clickhouse/tasks/main.yaml:7 Use `ansible.builtin.apt_repository` or `ansible.legacy.apt_repository` instead.

name[missing]: All tasks should be named.
roles/clickhouse/tasks/main.yaml:7 Task/Handler: apt_repository repo=deb {{ clickhouse_repository }} stable main state=present update_cache=False

yaml[truthy]: Truthy value should be one of [false, true]
roles/clickhouse/tasks/main.yaml:10

fqcn[action-core]: Use FQCN for builtin module actions (apt_key).
roles/clickhouse/tasks/main.yaml:11 Use `ansible.builtin.apt_key` or `ansible.legacy.apt_key` instead.

name[missing]: All tasks should be named.
roles/clickhouse/tasks/main.yaml:11 Task/Handler: apt_key url={{ clickhouse_gpg }} state=present

fqcn[action-core]: Use FQCN for builtin module actions (apt).
roles/clickhouse/tasks/main.yaml:14 Use `ansible.builtin.apt` or `ansible.legacy.apt` instead.

name[missing]: All tasks should be named.
roles/clickhouse/tasks/main.yaml:14 Task/Handler: apt update_cache=True force=True

yaml[truthy]: Truthy value should be one of [false, true]
roles/clickhouse/tasks/main.yaml:15

yaml[truthy]: Truthy value should be one of [false, true]
roles/clickhouse/tasks/main.yaml:16

fqcn[action-core]: Use FQCN for builtin module actions (apt).
roles/clickhouse/tasks/main.yaml:17 Use `ansible.builtin.apt` or `ansible.legacy.apt` instead.

name[missing]: All tasks should be named.
roles/clickhouse/tasks/main.yaml:17 Task/Handler: apt name=['{{ item }}={{ clickhouse_version }}'] state=present install_recommends=True

yaml[truthy]: Truthy value should be one of [false, true]
roles/clickhouse/tasks/main.yaml:21

fqcn[action-core]: Use FQCN for builtin module actions (meta).
roles/clickhouse/tasks/main.yaml:24 Use `ansible.builtin.meta` or `ansible.legacy.meta` instead.

yaml[new-line-at-end-of-file]: No new line character at the end of file
roles/clickhouse/tasks/main.yaml:25

yaml[new-line-at-end-of-file]: No new line character at the end of file
roles/clickhouse/vars/main.yml:7

fqcn[action-core]: Use FQCN for builtin module actions (apt).
roles/debian/tasks/main.yml:2 Use `ansible.builtin.apt` or `ansible.legacy.apt` instead.

yaml[truthy]: Truthy value should be one of [false, true]
roles/debian/tasks/main.yml:6

yaml[trailing-spaces]: Trailing spaces
roles/debian/tasks/main.yml:8

yaml[trailing-spaces]: Trailing spaces
roles/debian/tasks/main.yml:9

yaml[new-line-at-end-of-file]: No new line character at the end of file
roles/debian/vars/main.yml:6

yaml[new-line-at-end-of-file]: No new line character at the end of file
roles/vector/handlers/main.yml:7

fqcn[action-core]: Use FQCN for builtin module actions (apt_repository).
roles/vector/tasks/main.yml:7 Use `ansible.builtin.apt_repository` or `ansible.legacy.apt_repository` instead.

name[missing]: All tasks should be named.
roles/vector/tasks/main.yml:7 Task/Handler: apt_repository repo=deb {{ vector_repo_url }} stable vector-0 state=present update_cache=False

yaml[indentation]: Wrong indentation: expected 6 but found 4
roles/vector/tasks/main.yml:7

yaml[indentation]: Wrong indentation: expected 10 but found 8
roles/vector/tasks/main.yml:8

yaml[truthy]: Truthy value should be one of [false, true]
roles/vector/tasks/main.yml:10

fqcn[action-core]: Use FQCN for builtin module actions (apt_key).
roles/vector/tasks/main.yml:11 Use `ansible.builtin.apt_key` or `ansible.legacy.apt_key` instead.

name[missing]: All tasks should be named.
roles/vector/tasks/main.yml:11 Task/Handler: apt_key url={{ vector_gpg }} state=present

yaml[indentation]: Wrong indentation: expected 10 but found 8
roles/vector/tasks/main.yml:12

fqcn[action-core]: Use FQCN for builtin module actions (apt).
roles/vector/tasks/main.yml:14 Use `ansible.builtin.apt` or `ansible.legacy.apt` instead.

name[missing]: All tasks should be named.
roles/vector/tasks/main.yml:14 Task/Handler: apt update_cache=True force=True

yaml[truthy]: Truthy value should be one of [false, true]
roles/vector/tasks/main.yml:15

yaml[indentation]: Wrong indentation: expected 10 but found 8
roles/vector/tasks/main.yml:15

yaml[truthy]: Truthy value should be one of [false, true]
roles/vector/tasks/main.yml:16

fqcn[action-core]: Use FQCN for builtin module actions (apt).
roles/vector/tasks/main.yml:17 Use `ansible.builtin.apt` or `ansible.legacy.apt` instead.

name[missing]: All tasks should be named.
roles/vector/tasks/main.yml:17 Task/Handler: apt name=['{{ item }}'] state=present install_recommends=True

yaml[indentation]: Wrong indentation: expected 10 but found 8
roles/vector/tasks/main.yml:18

yaml[indentation]: Wrong indentation: expected 12 but found 10
roles/vector/tasks/main.yml:19

yaml[truthy]: Truthy value should be one of [false, true]
roles/vector/tasks/main.yml:21

yaml[indentation]: Wrong indentation: expected 6 but found 4
roles/vector/tasks/main.yml:26

yaml[octal-values]: Forbidden implicit octal value "0644"
roles/vector/tasks/main.yml:27

yaml[indentation]: Wrong indentation: expected 6 but found 4
roles/vector/tasks/main.yml:32

yaml[octal-values]: Forbidden implicit octal value "0644"
roles/vector/tasks/main.yml:33

fqcn[action-core]: Use FQCN for builtin module actions (meta).
roles/vector/tasks/main.yml:36 Use `ansible.builtin.meta` or `ansible.legacy.meta` instead.

yaml[new-line-at-end-of-file]: No new line character at the end of file
roles/vector/tasks/main.yml:37

yaml[trailing-spaces]: Trailing spaces
roles/vector/vars/main.yml:8

yaml[new-line-at-end-of-file]: No new line character at the end of file
roles/vector/vars/main.yml:21

syntax-check[unknown-module]: couldn't resolve module/action 'community.docker.docker_image'. This often indicates a misspelling, missing collection, or incorrect module path.
site.yml:6:7

Read documentation for instructions on how to ignore specific rule violations.

                       Rule Violation Summary                        
 count tag                           profile    rule associated tags 
     1 syntax-check[unknown-module]  min        core, unskippable    
     8 name[missing]                 basic      idiom                
     8 yaml[indentation]             basic      formatting, yaml     
     7 yaml[new-line-at-end-of-file] basic      formatting, yaml     
     2 yaml[octal-values]            basic      formatting, yaml     
     3 yaml[trailing-spaces]         basic      formatting, yaml     
     9 yaml[truthy]                  basic      formatting, yaml     
    11 fqcn[action-core]             production formatting           

Failed: 49 failure(s), 0 warning(s) on 9 files.
alekseykashin@MBP-Aleksej playbook %  ansible-playbook site.yml -i ./inventory/prod.yml
```

4. Правим / приводим код к стандарту, ошибки все исправил

```bash
alekseykashin@MBP-Aleksej playbook % ansible-lint site.yml                             
WARNING  Listing 1 violation(s) that are fatal
jinja[spacing]: Jinja2 spacing could be improved: create_db.rc != 0 and create_db.rc !=82 -> create_db.rc != 0 and create_db.rc != 82 (warning)
site.yml:54 Jinja2 template rewrite recommendation: `create_db.rc != 0 and create_db.rc != 82`.

Read documentation for instructions on how to ignore specific rule violations.

              Rule Violation Summary               
 count tag            profile rule associated tags 
     1 jinja[spacing] basic   formatting (warning) 

Passed: 0 failure(s), 1 warning(s) on 9 files. Last profile that met the validation criteria was 'min'.
alekseykashin@MBP-Aleksej playbook % 
```

5. Проверяем ```playbook``` на возможные изменения через команду `--check || - C`, файл с логом [run_playbook_check](run_playbook_check.log)

6. Поверем `playbook` через команду `--diff`, файл с логом [run_playbook_diff](run_playbook_diff.log), запускаем еще раз убеждаемся что ничего не изменилось [run_playbook_diff_again](run_playbook_diff_again.log)

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
