list=./sra.list
data=./sra/
index=./GRCh38/

mkdir -p $data

for x in `cat $list`
do
  fastq-dump --split-files --gzip --outdir $data $x
  STAR --outSAMstrandField intronMotif --chimSegmentMin 20 --runThreadN 6 --genomeDir $index --readFilesIn $data/${x}_1.fastq.gz $data/${x}_1.fastq.gz 
  rm $data/${x}_1.fastq.gz $data/${x}_1.fastq.gz
done
