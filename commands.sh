curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=auth-service' \
  --data 'url=http://mockbin.org/bin/7dcb0f87-e49b-4fb0-bd53-a4e8ecd6a00e'

curl -X DELETE http://localhost:8001/services/7dca5c85-a49c-46de-9bcb-91e975372b42
curl -X DELETE http://localhost:8001/services/auth-service/routes/fed7511b-c2b6-49ad-a11b-39bb2d98899c

curl -i -X GET http://localhost:8001/services/
curl -i -X GET http://localhost:8001/services/auth-service/routes

  --url http://localhost:8001/services/

curl -i -X DELETE \
  --url http://localhost:8001/services/ \
  --data 'name=auth-service' \

curl -i -X POST \
  --url http://localhost:8001/services/auth-service/routes \
  --data 'hosts[]=test-auth-plugin'

curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: test-auth-plugin'

kong migrations bootstrap --force
kong start


curl -i -X POST \
 --url http://localhost:8001/services/auth-service/plugins/ \
 --data 'name=auth' \
 --data 'config.response_header=Plugin-Version'
