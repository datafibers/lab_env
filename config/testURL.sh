set -e
. ./config/install_version.sh

for i in `(( set -o posix ; set ) | grep dl_link_ | cut -d "=" -f 2)`; do
res=$(wget --spider $i -nv --header="Cookie: oraclelicense=accept-securebackup-cookie" 2>&1)
if [[ $res = *"OK"* ]]; then
  echo $res
  continue
else
  echo "$res is broken!!"
  exit 1
fi
done
