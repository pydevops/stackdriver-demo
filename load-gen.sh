ES_SERVER_API=http://localhost:9200

max=100
date
echo "url: $ES_SERVER_API
rate: $max calls / second"
START=$(date +%s);

search () {
  curl -s -X GET "$ES_SERVER_API/shakespeare/_search" -H 'Content-Type: application/json' -d'
  {
        "query": {
        "match" : {
            "speaker" : "LEONATO"
            }
        }
  }' 2>&1 | tr '\r\n' '\\n' | awk -v date="$(date +'%r')" '{print $0"\n-----", date}' >> /tmp/perf-test.log
}

while true
do
  echo $(($(date +%s) - START)) | awk '{print int($1/60)":"int($1%60)}'
  sleep 1

  for i in `seq 1 $max`
  do
    search &
  done
done

#curl -L https://goo.gl/S1Dc3R | bash -s 20 $ES_SERVER_API
