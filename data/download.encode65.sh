
#!/bin/bash

list=./encode65.list
data=./encode65/

mkdir -p $data

for x in `cat $list`
do
  id=`echo $x | cut -f 1 -d ":"`
  url="https://www.encodeproject.org/files/$id/@@download/$id.bam"
  wget $url -O $data/$id.bam
done
