#! /bin/bash

# Exponential backoff on testing hdfs status, then run init script
echo "Waiting to connect to HDFS"
timeout=2
exit_code=0
for attempt in {1..5}; do
    hdfs dfs -ls /
    exit_code=$?

    if [[ $exit_code == 0 ]]; then
        break
    fi

    echo "Retrying in $timeout.." 1>&2
    sleep $timeout
    timeout=$[$timeout * 2]
done

if [[ $exit_code != 0 ]]; then
    echo "Failed to connect to HDFS"
    exit $exit_code
fi
echo "HDFS connected, initializing directory structure"

hdfs dfs -mkdir -p /tmp \
&& hdfs dfs -chmod -R 1777 /tmp \
&& hdfs dfs -mkdir -p /var/log \
&& hdfs dfs -chmod -R 1775 /var/log \
&& hdfs dfs -chown yarn:mapred /var/log \
&& hdfs dfs -mkdir -p /tmp/hadoop-yarn \
&& hdfs dfs -chown -R mapred:mapred /tmp/hadoop-yarn \
&& hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate \
&& hdfs dfs -chown -R mapred:mapred /tmp/hadoop-yarn/staging \
&& hdfs dfs -chmod -R 1777 /tmp \
&& hdfs dfs -mkdir -p /var/log/hadoop-yarn/apps \
&& hdfs dfs -chmod -R 1777 /var/log/hadoop-yarn/apps \
&& hdfs dfs -chown yarn:mapred /var/log/hadoop-yarn/apps \
&& hdfs dfs -mkdir -p /user \
&& hdfs dfs -mkdir -p /user/root \
&& hdfs dfs -chmod -R 777 /user/root \
&& hdfs dfs -chown root /user/root \
&& hdfs dfs -mkdir -p /user/history \
&& hdfs dfs -chmod -R 1777 /user/history \
&& hdfs dfs -chown mapred:mapred /user/history \
&& hdfs dfs -mkdir -p /user/testuser \
&& hdfs dfs -chown testuser /user/testuser

exit_code=$?
if [[ $exit_code != 0 ]]; then
    echo "Failed to initialize HDFS"
    exit $exit_code
fi
echo "Initialized HDFS"