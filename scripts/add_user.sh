#!/bin/bash
USER_HASH=$(echo $AUTH_USERNAME|md5sum|awk '{print $1}')
no_file=true

func_get_info () {
while [ "$no_file" == "true" ]
do
  [ -f /users/$USER_HASH/config/peer$PEERS/peer$PEERS.conf ] && no_file=false
done

zip -q -j /users/$AUTH_USERNAME.zip $(ls -1v /users/$USER_HASH/config/peer*/peer*.conf) $(ls -1v /users/$USER_HASH/config/peer*/peer*.png)
cat << _EOF_
<!DOCTYPE html>
<html>
<head>

</head>
<body>

<h3>Download ZIP archive below</h3>

</body>
</html>

_EOF_
}

if [ -d /users/$USER_HASH ]
then
  ID=$(grep -r  "ID=" /users/$USER_HASH/.env | awk -F'=' '{print $2}'|sort -h |tail -1)
else
  ID=$(grep -r  "ID=" /users/*/.env | awk -F'=' '{print $2}'|sort -h |tail -1)
  ((ID++))
  cp -pr /app/conf/scripts/user_template /users/$USER_HASH
fi

[ $ID -ge 250 ] && echo "Error: Max users" && exit 1

echo USER_HASH=$USER_HASH > /users/$USER_HASH/.env
echo PEERS=$PEERS >> /users/$USER_HASH/.env
echo ID=$ID >> /users/$USER_HASH/.env
echo IP=$ID >> /users/$USER_HASH/.env
echo PORT="51$(printf "%03d\n" $ID)" >> /users/$USER_HASH/.env

ssh docker@host.local "cd /home/docker/vpn/script-server-vpn/users/$USER_HASH && docker compose up -d --force-recreate" >/dev/null 2>$1

func_get_info
