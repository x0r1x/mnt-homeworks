resource "local_file" "hosts_templatefile" {
  content = templatefile(
    "${path.module}/hosts.tftpl", 
    { 
        group_hosts = tolist(
            [
                {
                    group = "teamcity"
                    hosts = [yandex_compute_instance.vms-machine["teamcity"]]
                },
                # {
                #     group = "teamcity-agent"
                #     hosts = [yandex_compute_instance.vms-machine["teamcity-agent"]]
                # }
            ]
        )
    }
  )
  filename = "${abspath(path.module)}/hosts.yml"
}
