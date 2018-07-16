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

params = ["M","a","f","g","j","m","t","u"]

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
    if(params[i] == "t" or params[i] == "u"):
        if p == "1":
            f.write(params[i] + "\n")
    else:
        f.write(params[i] + "\t" + p + "\n")
    i+=1

f.write("c\t0.001\n")
f.close();
