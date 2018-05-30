#!/bin/bash
if [ -d "$ELASTICSEARCH_INDEX_TEMPLATES" ]; then
  cd $ELASTICSEARCH_INDEX_TEMPLATES
  for template in *.json
  do
    NAME=$(echo $template | cut -d"." -f1)
    EXISTS=$(curl -s -I "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME" -H 'Content-Type: application/json' | head -n1)
    if [[ $EXISTS == *"404"* ]]; then
      curl -s -X PUT "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME" -H 'Content-Type: application/json' -d @$template
    fi
    if [[ $EXISTS == *"200"* ]]; then
      ES_VERSION=$(curl -s -X GET "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME?filter_path=*.version" -H 'Content-Type: application/json' | sed 's/[^0-9]*//g')
      FILE_VERSION=$(cat $template | grep '"version": ' | sed 's/[^0-9]*//g')
      if [[ "$ES_VERSION" != "$FILE_VERSION" ]]; then
        echo "Template version of $NAME does not match - Updating"
        curl -s -X PUT "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME" -H 'Content-Type: application/json' -d @$template
      fi
    fi
  done
fi