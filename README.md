# stackdriver-demo


## Install monitoring agent on GCE instance

[Install stackdriver monitoring agent](https://cloud.google.com/monitoring/agent/install-agent#linux-install)

This is useful to gather the metrics such as memory usage. 

```code
curl -sSO https://dl.google.com/cloudagents/install-monitoring-agent.sh
sudo bash install-monitoring-agent.sh
```

## Configure JVM plugin for the monitoring agent

[install JVM plugin](https://cloud.google.com/monitoring/agent/plugins/jvm)
```code
sudo -i
cd /opt/stackdriver/collectd/etc/collectd.d/ 
curl -O https://raw.githubusercontent.com/Stackdriver/stackdriver-agent-service-configs/master/etc/collectd.d/jvm-sun-hotspot.conf

JMX_PORT=9100
sed -i "s/localhost:JMX_PORT/localhost:$JMX_PORT/g" /opt/stackdriver/collectd/etc/collectd.d/jvm-sun-hotspot.conf
```

### Notes on RHEL 7

1. [Download Oracle JDK RPM](from http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) accordingly. Please note that JRE should work too. 
2. Copy the rpm to the GCP instance and install JDK.
```code
gcloud compute scp jdk-8u181-linux-x64.rpm <gcp_instance_name>:/tmp
gcloud compute ssh <gcp_instance_name>
rpm -ivh /tmp/jdk-8u181-linux-x64.rpm
# to verify the installation
yum list jdk1.8.x86_64
```
3. Restart stackdriver-agent
```code
systemctl restart stackdriver-agent
systemctl status stackdriver-agent
journalctl -u stackdriver-agent
```

## Configure WAS JVM for JMX
[Enabling JMX for WAS](https://www.splunk.com/blog/2015/07/13/enabling-jmx-in-websphere-application-server.html)


## Configure ElasticSearch JVM for JMX

```
cat <<EOF >>/etc/elasticsearch/jvm.options
-Dcom.sun.management.jmxremote.port=9100
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
EOF"
```

## load generation

### start the SSH port forwarding for ElasticSearch cluster
To make it easier, we will port forwarding 9200 from local to the cluster running in the GCE. Please note this can be copied from the Terraform output. 
```code
gcloud compute ssh --ssh-flag="-A -L :9200:localhost:9200 " $(terraform output es_instance)
```

### load shakespare data
```code
./load-shakspeare.sh
```
### load generation

```code
ab -k -n 1000 -c 10 http://localhost:9200/shakespeare
```



## References
[Agent Metrics List](https://cloud.google.com/monitoring/api/metrics_agent)