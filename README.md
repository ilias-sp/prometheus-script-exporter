## > About

script_exporter for Prometheus. When scraped, it will trigger user-provided shell scripts that follow a specific "protocol", and return their exit code and stdout output as metrics for storing in Prometheus TSDB.

The shell scripts will be referred to as "jobs" in this guide.

## > Prerequisites

The exporter is written in Python, and uses several Python packages. You can download manually, or use the `requirements.txt` provided in the repo to install them:

```
python3 -m pip install -r requirements.txt
```
## > Installation

To start the script_exporter, the below files are needed:

```
├── script_exporter
├── script_exporter.service
├── script_exporter.yml
├── scripts
│   ├── check_cpu_temperature.sh
│   ├── check_process_running.sh
│   ├── echo_argument.sh
│   └── return_failure.sh
```

| File | Description |
| ----------------------- | ----------------------- |
| script_exporter | the python module, the actual exporter |
| script_exporter.service | this file can be modified, then copied to `/etc/systemd/system` in order to run the exporter as a service. |
| script_exporter.yml | the file containing the jobs(shell scripts) the exporter can run when triggered by Prometheus. |
| scripts | a folder where all shell scripts are meant to be found |


## > Configuration

1. clone the repo or download the ZIP.
2. copy the `script_exporter.yml.template` to `script_exporter.yml` and customize it.
3. if you are planning to run the exporter as a service, copy the `script_exporter.service.template` to `/etc/systemd/system` and customize it. You will need to replace the `<define the user to run the exporter>`, `<define the dir the exporter was installed>`, `<port to listen>` with your desired settings. 

Then enable and start the service by: 

```
systemctl enable script_exporter 
systemctl start script_exporter 
```

4. to enable scraping from Prometheus, you can add a section as below in its configuration file:

```yaml
...
...
  - job_name: 'script-exporter'
    scrape_interval: 120s
    scrape_timeout: 10s
    metrics_path: /probe
    params:
      job: [all]

    static_configs:
      - targets:
        - node1
        - node2
        - node3
    relabel_configs:
    - source_labels: [__address__]
      target_label: instance
    - source_labels: [__address__]
      regex: ^(.*)$
      target_label: __address__
      replacement: $1:8103
...
...
```

## > Testing the script_exporter

To test that the exporter produces the metrics, you can scrape it by accessing its service url and the job you wish to trigger. Sample output can be seen below:

- probing for a specific job:

```
[ilias@pi4 system] > curl http://127.0.0.1:8103/probe?job=check_cpu_temperature          
# HELP script_exporter_script_success Script exit status (0 = error, 1 = success).
# TYPE script_exporter_script_success gauge
script_exporter_script_success{script="check_cpu_temperature"} 1
script_exporter_script_output{script="check_cpu_temperature"} 45.30
[ilias@pi4 system] > 
```

- probing for all jobs:

```
[ilias@pi4 system] > curl http://127.0.0.1:8103/probe?job=all
# HELP script_exporter_script_success Script exit status (0 = error, 1 = success).
# TYPE script_exporter_script_success gauge
script_exporter_script_success{script="check_lan_hosts"} 1
script_exporter_script_output{script="check_lan_hosts"} 5
# HELP script_exporter_script_success Script exit status (0 = error, 1 = success).
# TYPE script_exporter_script_success gauge
script_exporter_script_success{script="check_cpu_temperature"} 1
script_exporter_script_output{script="check_cpu_temperature"} 44.30
[ilias@pi4 system] > 
```

## > Issues

Feel free to open an issue for questions of if something seems off.
