resource "local_file" "hosts_templatefile" {
  content = templatefile(
    "${path.module}/hosts.tftpl", 
    { 
        group_hosts = tolist(
            [
                {
                    group = "clickhouse"
                    hosts = [yandex_compute_instance.vms-machine["clickhouse"]]
                },
                {
                    group = "vector"
                    hosts = [yandex_compute_instance.vms-machine["vector"]]
                },
                {
                    group = "lighthouse"
                    hosts = [yandex_compute_instance.vms-machine["lighthouse"]]
                }
            ]
        )
    }
  )
  filename = "${abspath(path.module)}/hosts.yml"
}
