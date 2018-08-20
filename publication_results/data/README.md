# Datasets

**These instructions adapted from [scalloptest](https://github.com/Kingsford-Group/scalloptest) repository**

## **encode10**
The first dataset, namely **encode10**,
contains 10 human RNA-seq samples downloaded from [ENCODE project (2003--2012)](https://genome.ucsc.edu/ENCODE/).
All these samples are sequenced with strand-specific and paired-end protocols.
For each of these 10 samples, we align it with three RNA-seq aligners,
[TopHat2](https://ccb.jhu.edu/software/tophat/index.shtml),
[STAR](https://github.com/alexdobin/STAR), and
[HISAT2](https://ccb.jhu.edu/software/hisat2/index.shtml).
We have uploaded all these reads alignments to CMU box.
Use this [link](https://cmu.box.com/s/1h6z11ee7ks2ij5xvnc8n9z9gdjeet52) to download these files.
Four reads alignment files are splitted and then uploaded due to single file size limit of CMU box:
all the three alignments of SRR387661 and the tophat alignment of SRR534307.
You need to merge them after downloading, for example:
```
cat tophat.sort.part1.bam tophat.sort.part2.bam > tophat.sort.bam
```
After that you can (optionally) remove `tophat.sort.part*.bam`.
**NOTE:** The total 30 reads alignments files take about 270GB storage space.
Please keep the identical directory structure and files names
(i.e., `data/encode10/ACCESSION/ALIGNER.sort.bam`) as we used there.


## **encode65**
The second dataset, namely **encode65**,
contains 65 human RNA-seq samples downloaded from [ENCODE project (2013--present)](https://www.encodeproject.org/).
This dataset includes 50 strand-specific samples and 15 non-strand samples.
These samples have pre-computed reads alignments, and can be downloaded by the script in `data` directory.
```
./download.encode65.sh
```
The downloaded files will appear under `data/encode65`.
**NOTE:** The total 65 reads alignments files take about 390GB storage space.

## **sra**
The last dataset contains all of the experements from the SRA that meet the requirements described in the paper. 
To download and align these 1597 samples, the following command should be run from the `data` directory.
```
./downloadAndAlign.sra.sh
```

A STAR index should of GRCH38 should be built into the folder `data/GRCh38` before running this script and the resulting alignments 
will be in `data/sra`.

**NOTE:**  This process will take a long time and the total size needed will be about 5TB and the process is not parellelized.