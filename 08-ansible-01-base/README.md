# Домашнее задание к занятию 1 «Введение в Ansible»

## Подготовка к выполнению

1. Установите Ansible версии 2.10 или выше.
2. Создайте свой публичный репозиторий на GitHub с произвольным именем.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.
2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на `all default fact`.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.
13. Предоставьте скриншоты результатов запуска команд.

#### Решение 

1. Запускаем playbook c интори файлом `test.yml`

    ```bash
    alekseykashin@MBP-Aleksej playbook % ansible-playbook -i ./invetory/test.yml site.yml  
    PLAY [Print os facts] ************************************************************************************

    TASK [Gathering Facts] ***********************************************************************************
    ok: [localhost]

    TASK [Print OS] ******************************************************************************************
    ok: [localhost] => {
        "msg": "MacOSX"
    }

    TASK [Print fact] ****************************************************************************************
    ok: [localhost] => {
        "msg": 12
    }

    PLAY RECAP ***********************************************************************************************
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

    alekseykashin@MBP-Aleksej playbook % 
    ```

2. Меняем значение переменной `some_fact:` для группы `all` на `all default fact`

    ```bash
    alekseykashin@MBP-Aleksej playbook % cat ./group_vars/all/examp.yml
    ---
    some_fact: "all default fact"%                                                                                              alekseykashin@MBP-Aleksej playbook % 
    ```

    провереяем что успешно переменная изменилась

    ```bash
    alekseykashin@MBP-Aleksej playbook % ansible-playbook -i ./invetory/test.yml site.yml
    PLAY [Print os facts] ********************************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************************
    ok: [localhost]

    TASK [Print OS] **************************************************************************************************************
    ok: [localhost] => {
        "msg": "MacOSX"
    }

    TASK [Print fact] ************************************************************************************************************
    ok: [localhost] => {
        "msg": "all default fact"
    }

    PLAY RECAP *******************************************************************************************************************
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

    alekseykashin@MBP-Aleksej playbook % 
    ```

3. Создаем и настраиваем окружение для дальнеших испытаний:
    - скачиваем образы `centos` и `ubuntu`

        ```bash
        alekseykashin@MBP-Aleksej playbook % docker pull ubuntu:latest                              
        latest: Pulling from library/ubuntu
        25a614108e8d: Pull complete 
        Digest: sha256:b359f1067efa76f37863778f7b6d0e8d911e3ee8efa807ad01fbf5dc1ef9006b
        Status: Downloaded newer image for ubuntu:latest
        docker.io/library/ubuntu:latest 
        ```

        ```bash
        alekseykashin@MBP-Aleksej playbook % docker pull centos:latest 
        latest: Pulling from library/centos
        52f9ef134af7: Pull complete 
        Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
        Status: Downloaded newer image for centos:latest
        docker.io/library/centos:latest
        ```

    - в `site.yml` добавляем новый `play` создание двух контейнеров [`centos7`, `ubuntu`]

    ```yml
    - name: docker container run
        hosts: localhost
        connection: local
        gather_facts: false 
        tasks:
        - name: create docker container for Centos7
            docker_container:
            name: centos7
            image: centos:latest
            state: started
            restart: yes
            restart_policy: always
            interactive: true
            tty: true
        - name: create docker container for Ubuntu
            docker_container:
            name: ubuntu
            image: ubuntu:latest
            state: started
            restart: yes
            restart_policy: always
            interactive: true
            tty: true
    ```

    - настраиваем хосты, устанавливаем python

    ```yml
    - name: Installing python on hosts
        hosts: [ubuntu, centos7]
        gather_facts: false
        tasks:
        - name: update pack manager and install python for ubuntu host
            raw: "{{ item }}"
            loop:
            - apt-get update
            - apt-get -y install python3
            when: inventory_hostname == 'ubuntu'
        - name: update pack manager and install python for centos7 host
            raw: "{{ item }}"
            loop:
            - sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
            - sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
            - yum -y update
            - yum -y install python39
            when: inventory_hostname == 'centos7'
    ```

4. Запускам playbook на окружении из `prod.yml`

    ```bash
    alekseykashin@MBP-Aleksej playbook %  ansible-playbook site.yml -i ./inventory/prod.yml

    PLAY [docker container run] ****************************************************************************************************************

    TASK [create docker container for Centos7] *************************************************************************************************
    changed: [localhost]

    TASK [create docker container for Ubuntu] **************************************************************************************************
    changed: [localhost]

    PLAY [Installing python on hosts] **********************************************************************************************************

    TASK [update pack manager and install python for ubuntu host] ******************************************************************************
    skipping: [centos7] => (item=apt-get update) 
    skipping: [centos7] => (item=apt-get -y install python3) 
    skipping: [centos7]
    changed: [ubuntu] => (item=apt-get update)
    changed: [ubuntu] => (item=apt-get -y install python3)

    TASK [update pack manager and install python for centos7 host] *****************************************************************************
    skipping: [ubuntu] => (item=sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*) 
    skipping: [ubuntu] => (item=sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*) 
    skipping: [ubuntu] => (item=yum -y update) 
    skipping: [ubuntu] => (item=yum -y install python39) 
    skipping: [ubuntu]
    changed: [centos7] => (item=sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*)
    changed: [centos7] => (item=sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*)
    changed: [centos7] => (item=yum -y update)
    changed: [centos7] => (item=yum -y install python39)

    PLAY [Print os facts] **********************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************
    [WARNING]: Platform linux on host ubuntu is using the discovered Python interpreter at /usr/bin/python3.12, but future installation of
    another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [ubuntu]
    [WARNING]: Platform linux on host centos7 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of
    another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [centos7]

    TASK [Print OS] ****************************************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************
    ok: [centos7] => {
        "msg": "el"
    }
    ok: [ubuntu] => {
        "msg": "deb"
    }

    PLAY RECAP *********************************************************************************************************************************
    centos7                    : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

    alekseykashin@MBP-Aleksej playbook % 
    ```

5. Меняю переменные `some_fact` для групп [`el`, `deb`] на `* default fact` (тут я не понял что надо конкретно сделать выгялдит похоже на пункт 2)

    ```bash
    alekseykashin@MBP-Aleksej playbook % cat ./group_vars/deb/examp.yml 
    ---
    some_fact: "deb default fact"% 
    alekseykashin@MBP-Aleksej playbook %
    ```

    ```bash
    alekseykashin@MBP-Aleksej playbook % cat ./group_vars/el/examp.yml
    ---
    some_fact: "el default fact"%
    alekseykashin@MBP-Aleksej playbook %
    ```

6. Запускаю `playbook` и проверяю пременные хостов

    ```bash
    alekseykashin@MBP-Aleksej playbook %  ansible-playbook site.yml -i ./inventory/prod.yml
    ...
    PLAY [Print os facts] **********************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************
    [WARNING]: Platform linux on host ubuntu is using the discovered Python interpreter at /usr/bin/python3.12, but future installation of
    another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [ubuntu]
    [WARNING]: Platform linux on host centos7 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of
    another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [centos7]

    TASK [Print OS] ****************************************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *********************************************************************************************************************************
    centos7                    : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

    alekseykashin@MBP-Aleksej playbook % 
    ```

7. Зашифровываем переменные [`group_vars/deb`, `group_vars/el`]
    - Зашифровываем переменные в `group_vars/deb`

        ```bash
        alekseykashin@MBP-Aleksej playbook % ansible-vault encrypt ./group_vars/deb/examp.yml
        New Vault password: 
        Confirm New Vault password: 
        Encryption successful
        ```

    - Проверяем

        ```bash
        alekseykashin@MBP-Aleksej playbook % cat ./group_vars/deb/examp.yml 
        $ANSIBLE_VAULT;1.1;AES256
        33353132656164356462356432343933393238316335373365303733613731306435306330666639
        6634366239623961323061373933343434643630386134310a653732393263346533653166313865
        35653365396435643963306236666430613931306666323533333631386561633234353934363539
        3463343235386362620a363061626630663863386432373737363832306331616563666362646165
        37313130393034333364646232333866653535663539633638633461633233356632376238326535
        6436363331336165313834613434636432646232323335313438
        alekseykashin@MBP-Aleksej playbook % 
        ```

    - Зашифровываем переменные в `group_vars/el`

        ```bash
        alekseykashin@MBP-Aleksej playbook % ansible-vault encrypt ./group_vars/el/examp.yml
        New Vault password: 
        Confirm New Vault password: 
        Encryption successful
        alekseykashin@MBP-Aleksej playbook % 
        ```

    - Проверяем

        ```bash
        alekseykashin@MBP-Aleksej playbook % cat ./group_vars/el/examp.yml
        $ANSIBLE_VAULT;1.1;AES256
        62353261363034353262323538623265333062613339346633643563613361336231653238356665
        3430353933626365633036616266633634333065316138620a313732656131623234353432333934
        33346232623864313563313637353262356132313961306339303061353165623865323837376638
        3232663864376630660a396231363432626662636333393637306539333333323337346336313232
        38656632613038616234313330656534613333613738656334626133343638653561613930313839
        3334653732323063343533666334346234336236616561336563
        alekseykashin@MBP-Aleksej playbook % 
        ```

8. Запускаю `playbook` и проверяю факты `some_fact`

    ```bash
    alekseykashin@MBP-Aleksej playbook %  ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
    Vault password: 

    PLAY [Print os facts] **********************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************
    [WARNING]: Platform linux on host ubuntu is using the discovered Python interpreter at /usr/bin/python3.12, but future installation of
    another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [ubuntu]
    [WARNING]: Platform linux on host centos7 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of
    another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [centos7]

    TASK [Print OS] ****************************************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *********************************************************************************************************************************
    centos7                    : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

    alekseykashin@MBP-Aleksej playbook % 
    ```

9. Смотрим все плагины для подключения через документацию `ansible-doc`.

    ```bash
    alekseykashin@MBP-Aleksej playbook % ansible-doc -l
    amazon.aws.autoscaling_group                                                  Create or delete AWS AutoScaling Gr...
    amazon.aws.autoscaling_group_info                                             Gather information about EC2 Auto S...
    amazon.aws.aws_az_info                                                        Gather information about availabili...
    amazon.aws.aws_caller_info                                                    Get information about the user and ...
    amazon.aws.aws_region_info                                                    Gather information about AWS region...
    amazon.aws.backup_plan                                                        Manage AWS Backup Plans            
    amazon.aws.backup_plan_info                                                   Describe AWS Backup Plans          
    amazon.aws.backup_restore_job_info                                            List information about backup resto...
    ...
    ```

    - Выбираем пакет который возможно понадобиться на управляющей ноде, будем думать что зная зону в облаке AWS мы что то дальше с ней сделаем.

        ```bash
        > MODULE amazon.aws.aws_az_info (/opt/homebrew/Cellar/ansible/10.4.0/libexec/lib/python3.12/site-packages/ansible_collections/amazon/aws/plugins/modules/aws_az_info.py)

        Gather information about availability zones in AWS.
        ...
        ```

10. Добавляю новую группу `local` в `prod.yaml` инветори

    ```yml
    local:
        hosts:
        localhost:
            ansible_connection: local
            ansible_python_interpreter: "{{ansible_playbook_python}}"
    ```

11. Запускаю `playbook` и проверяю факты `some_fact`

    ```bash
    alekseykashin@MBP-Aleksej playbook %  ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
    Vault password: 

    ...

    PLAY [Print os facts] *********************************************************************************************************************************

    TASK [Gathering Facts] ********************************************************************************************************************************
    ok: [localhost]
    [WARNING]: Platform linux on host ubuntu is using the discovered Python interpreter at /usr/bin/python3.12, but future installation of another Python
    interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for
    more information.
    ok: [ubuntu]
    [WARNING]: Platform linux on host centos7 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python
    interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for
    more information.
    ok: [centos7]

    TASK [Print OS] ***************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }
    ok: [localhost] => {
        "msg": "MacOSX"
    }

    TASK [Print fact] *************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }
    ok: [localhost] => {
        "msg": "all default fact"
    }

    PLAY RECAP ********************************************************************************************************************************************
    centos7                    : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

    alekseykashin@MBP-Aleksej playbook % 
    ```

---

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот вариант](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в ваш личный репозиторий.

#### Решение 

1. Расшифровываем групповые переменные [`group_vars/deb`, `group_vars/el`]

    ```bash
    alekseykashin@MBP-Aleksej playbook % ansible-vault decrypt ./group_vars/el/examp.yml
    Vault password: 
    Decryption successful
    alekseykashin@MBP-Aleksej playbook % cat ./group_vars/el/examp.yml
    ---
    some_fact: "el default fact"%                                                                                                      alekseykashin@MBP-Aleksej playbook % ansible-vault decrypt ./group_vars/deb/examp.yml
    Vault password: 
    Decryption successful
    alekseykashin@MBP-Aleksej playbook % cat ./group_vars/deb/examp.yml                
    ---
    some_fact: "deb default fact"%                                                                                                     alekseykashin@MBP-Aleksej playbook % 
    ```

2. Зашифровываем пароль как строку

    ```bash
    alekseykashin@MBP-Aleksej playbook % ansible-vault encrypt_string PaSSw0rd
    New Vault password: 
    Confirm New Vault password: 
    Encryption successful
    !vault |
            $ANSIBLE_VAULT;1.1;AES256
            38653163383231613235306139303536616131343034353264353132376639396263636162663834
            6130396630336365356232633863633863346635393861350a386231613262396262653061303237
            64303863303632376234613234353833653532353063346636366363353761383461623961393235
            3432623536613334640a393030656365383937313733623635643664353133613134386238363066
            3566
    ```

    - добавляем новую группову переменную `group_vars/all/exmp.yml` c зашифрованным паролем

        ```bash
        alekseykashin@MBP-Aleksej playbook % cat ./group_vars/all/exmp.yml
        ---
        some_fact: !vault |
                $ANSIBLE_VAULT;1.1;AES256
                38653163383231613235306139303536616131343034353264353132376639396263636162663834
                6130396630336365356232633863633863346635393861350a386231613262396262653061303237
                64303863303632376234613234353833653532353063346636366363353761383461623961393235
                3432623536613334640a393030656365383937313733623635643664353133613134386238363066
                3566%                                                                                                                      alekseykashin@MBP-Aleksej playbook % 
        ```

3. Запускаю `playbook` и проверяю факты `some_fact`, применился для `localhost`

    ```bash
    alekseykashin@MBP-Aleksej playbook %  ansible-playbook site.yml -i ./inventory/prod.yml --ask-vault-password
    Vault password: 

    ...

    PLAY [Print os facts] ******************************************************************************

    TASK [Gathering Facts] *****************************************************************************
    ok: [localhost]
    [WARNING]: Platform linux on host ubuntu is using the discovered Python interpreter at
    /usr/bin/python3.12, but future installation of another Python interpreter could change the meaning
    of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [ubuntu]
    [WARNING]: Platform linux on host centos7 is using the discovered Python interpreter at
    /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning
    of that path. See https://docs.ansible.com/ansible-
    core/2.17/reference_appendices/interpreter_discovery.html for more information.
    ok: [centos7]

    TASK [Print OS] ************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }
    ok: [localhost] => {
        "msg": "MacOSX"
    }

    TASK [Print fact] **********************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }
    ok: [localhost] => {
        "msg": "PaSSw0rd"
    }

    PLAY RECAP *****************************************************************************************
    centos7                    : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

    alekseykashin@MBP-Aleksej playbook % 
    ```

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
