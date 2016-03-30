HELP="Takes a single integer argument master or slave"
NODE_TYPE=$1

sudo apt-get update
# Download scala and install it
wget http://downloads.typesafe.com/scala/2.11.7/scala-2.11.7.deb
sudo dpkg -i scala-2.11.7.deb

# Download and setup Spark
wget http://apache.arvixe.com/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz
sudo tar zxvf ~/spark-* -C /usr/local
sudo mv /usr/local/spark-* /usr/local/spark
echo "export SPARK_HOME=/usr/local/spark" | sudo tee -a ~/.profile
echo "export PATH=$PATH:/usr/local/spark/bin" | sudo tee -a ~/.profile
source ~/.profile
sudo chown -R ubuntu $SPARK_HOME
cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
echo 'export JAVA_HOME=/usr' | sudo tee -a $SPARK_HOME/conf/spark-env.sh
#echo 'export SPARK_PUBLIC_DNS="current_node_public_dns"' | sudo tee -a $SPARK_HOME/conf/spark-env.sh
echo 'export SPARK_WORKER_CORES=6' | sudo tee -a $SPARK_HOME/conf/spark-env.sh

if [ $NODE_TYPE == 'master' ]; then
    touch $SPARK_HOME/conf/slaves
    echo '172.31.32.51' | sudo tee -a $SPARK_HOME/conf/slaves
    echo '172.31.32.52' | sudo tee -a $SPARK_HOME/conf/slaves
    echo '172.31.32.53' | sudo tee -a $SPARK_HOME/conf/slaves
    echo "Starting master"
    #$SPARK_HOME/sbin/start-master.sh
elif [ $NODE_TYPE == 'slave' ]; then
    echo "Starting slave"
    #$SPARK_HOME/sbin/start-slave.sh 172.31.32.51:7077
    
else
    echo $HELP
    exit 1
fi




# cat <<EOF
# EOF > run_spark.sh
# #!/bin/bash
# /home/ubuntu/spark-1.6.1-bin-hadoop2.6/bin/spark-shell --packages com.datastax.spark:spark-cassandra-connector_2.10:1.5.0-M3
# EOF

# chmod +x run_spark.sh
# EOF
