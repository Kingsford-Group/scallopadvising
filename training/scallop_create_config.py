import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import argparse
import re
import os

parser = argparse.ArgumentParser(description='Plot the increasing AUC values.')
parser.add_argument('folder', type=str)
parser.add_argument('-out_fname', dest='out_fname', type=str, default="max.tsv")

args = parser.parse_args()

f = open(args.out_fname,'w')

params = ["max_dp_table_size","max_edit_distance","max_intron_contamination_coverage","max_num_exons","min_bundle_gap","min_exon_length","min_flank_length","min_mapping_quality","min_num_hits_in_bundle","min_router_count","min_splice_boundary_hits","min_subregion_gap","min_subregion_length","min_subregion_overlap","min_transcript_length_base","min_transcript_length_increase","uniquely_mapped_only","use_second_alignment"]

mx = 0
max_config = "";

files = os.popen("ls -tr " + args.folder + "*.auc").readlines()
for fname in files:
    line = open(fname.rstrip()).read()
    m = re.match(".*auc = (.*)", line)
    if(line != ""  and float(m.group(1)) > mx):
        mx = float(m.group(1))
        max_config = fname;

i = 0
for p in re.sub('.auc','',re.sub(r'.*\/_','',max_config.rstrip())).split("_"):
    f.write(params[i] + "\t" + p + "\n")
    i+=1

.write("min_transcript_coverage\t0\n")
f.close();
