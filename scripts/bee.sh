service=${1:-hql2}
echo "hql  - connect to hive 1.2"
echo "hql2 - connect to hive 2.1.0 (defaut)"
echo "sql  - connect to spark sql"

if [ "${service}" = "hql2" ]; then
 port=10500
elif [ "${service}" = "sql" ]; then
 port=10016
else
 port=10000
fi

url="jdbc:hive2://localhost:"${port}
beeline -u ${url} -n vagrant
