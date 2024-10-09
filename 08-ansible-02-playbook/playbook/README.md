
- [Homework Project Ansible-Playbook](#homework-project-ansible-playbook)
- [Homework Installation](#homework-installation)
  - [Prerequisite](#prerequisite)
  - [Install](#install)
  - [Custom configuration files](#custom-configuration-files)
- [Getting Help](#getting-help)
- [License](#license)
- [Copyright](#copyright)

## Homework Project Ansible-Playbook

Repository the second homework of the Ansible

## Homework Installation

This ansible playbook supports the following,

- Supports most popular **Linux distributions**(Ubuntu)
- Install and configure the Clickhouse, Vector
- Create database on Clickhouse
- Overriding default settings with your own

### Prerequisite

    - **Ansible 2.17+**

### Install

    # Deploy with ansible playbook - run the playbook as root
    ansible-playbook site.yml -i ./inventory/prod.yml

### Custom configuration files

To override the default settings files, you need to put your settings in the `template` directory. The files should be 
named exactly the same as the original ones (internal_users.yml, roles.yml, tenants.yml, etc.)

## Getting Help

If you find a bug, or have a feature request, please don't hesitate to open an issue in this repository.

## License

This project is licensed under the [Apache v2.0 License].

## Copyright

Copyright Nettlolgy Contributors.
