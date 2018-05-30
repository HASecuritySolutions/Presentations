if [ -d "$SAMPLE_INDEX_FOLDER" ]; then
  cd $SAMPLE_INDEX_FOLDER
  for logs in *.json
  do
    NAME=$(echo $logs | cut -d"." -f1)
    EXISTS=$(curl -s -I "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/$NAME" -H 'Content-Type: application/json')
    if [[ $EXISTS == *"404"* ]]; then
      echo "Index $NAME does not exist. Creating..."
      PORT_STATUS=0
      COUNT=0
      while [ $PORT_STATUS -eq 0 ]; do
        TEST=$(nc -z -v "$LOGSTASH_HOST" "$LOGSTASH_JSON_PORT" 2>&1 | grep 60000)
        if [[ $TEST == *"open"* ]]; then
          IMPORT=$(nc "$LOGSTASH_HOST" "$LOGSTASH_JSON_PORT" -q 1 < "$SAMPLE_INDEX_FOLDER/$logs")
          PORT_STATUS=1
        else
          if [ $COUNT -lt 180 ]; then
            echo "Waiting on Logstash to come online - $COUNT seconds"
            sleep 5
            COUNT=$(($COUNT+5))
          else
            PORT_STATUS=2
          fi
        fi
      done
    fi
    if [[ $EXISTS == *"200"* ]]; then
      echo "Index $NAME already exists"
    fi
  done
fi