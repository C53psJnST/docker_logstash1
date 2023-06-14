

mkdir -p /data/elk/logstash/conf.d
mkdir -p /data/elk/logstash/txtfile

#################
tee /data/elk/logstash/logstash.yml <<-'EOF'

#path.config: /usr/share/logstash/conf.d/*.conf
#path.logs: /var/log/logstash
http.host: "0.0.0.0"
#ES地址
xpack.monitoring.elasticsearch.hosts: ["http://192.168.79.40:9200"] 
xpack.monitoring.enabled: true
#ES中的内置账户和密码，在ES中配置
#xpack.monitoring.elasticsearch.username: logstash_system    
#xpack.monitoring.elasticsearch.password: *****************

EOF




#################
tee /data/elk/logstash/conf.d/my.conf <<-'EOF'

input {
    file{
    	#docker中logstash内部的地址(可以通过数据卷来进行同步)
        path => "/usr/share/logstash/txtfile/**"
        #可选项，表示从哪个位置读取文件数据，初次导入为：beginning，最新数据为：end
        start_position => beginning
        #可选项，logstash多久检查一次被监听文件的变化，默认1s;
        stat_interval => 1
        #可选项，logstash多久检查一下path下有新文件，默认15s;
        discover_interval => 1
    }
 }


output {
            elasticsearch {
                #es地址ip端口
                hosts => ["192.168.79.40:9200"]
                #索引
                # 需要在 ES里， 先执行 PUT /txt_index 创建索引
                index => "txt_index"
            }

		#日志输出
       stdout {
       # codec => json_lines
    }
}

EOF


####################
docker run -di  --restart=always                    \
  --log-driver json-file           \
  --log-opt max-size=100m          \
  --log-opt max-file=2             \
  -p 5044:5044                     \
  -p 9600:9600                     \
  --name LO                  \
  --network=host                               \
  -v /data/elk/logstash/logstash.yml:/usr/share/logstash/config/logstash.yml \
  -v /data/elk/logstash/conf.d/:/usr/share/logstash/conf.d/ \
  logstash:7.8.0


