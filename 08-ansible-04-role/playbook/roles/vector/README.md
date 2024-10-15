ansible-vector
=========

The role installs and configures the Vector on selected hosts

Requirements
------------

The role is installed only on the Debian OS family

Role Variables
--------------

F: You can configure vector.

```yaml
vector_config:
  data_dir: "/var/lib/vector"
  sources:
    demo_logs:
      type: demo_logs
      format: syslog
    in:
      type: stdin
  sinks:
    print:
      type: "console"
      inputs:
        - "demo_logs"
      encoding:
        codec: "text"
```

Dependencies
------------

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: vector
  become: true
  vars:
    vector_config:
      sources:
        demo_logs:
          type: demo_logs
          format: syslog
        in:
          type: stdin
      sinks:
        to_clickhouse:
          type: clickhouse
          inputs:
            - demo_logs
          database: vector
          endpoint: http://localhost:8123
          table: server_log
          compression: gzip
          healthcheck: true
          skip_unknown_fields: true
  roles:
    - vector
```

License
-------

MIT

Author Information
------------------

Aleksey Kashin.
