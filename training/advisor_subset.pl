#!/usr/bin/perl
use strict;
use warnings;

# this script takes in a folder containing a set of files containing the AUC information for a set of training examples
# each assembles using a collection of trained parameter choice vectors. These files should have the naming convetion
# <example>_c<configuration>.auc
# An ILP is then generated to solve the advisor subset problem, this ILP is saved to a file, CPLEX is called and the results
# are postprocessed and the final subset is printed to STDOUT

my $folder = shift;     #folder continina the AUC files
my $file = shift;       #location/name of the temporaray LP file read and write
my $num_params = shift; #goal advisor set size

# running ILP strings
my $objective = "\t";
my $sum_1_constraints = "";
my $param_exists_constraints = "";

# book keeping
my $experements = -1;
my @experement_names;
my %parameters;
my @parameters_inverse;

foreach my $exp(`ls $folder/*auc | sed "s/.*\\/\\(.*\\)_c.*/\\1/" | sort -u`){
  chomp $exp;
  print STDERR "Reading $exp\r";
  push(@experement_names,$exp);
  $experements++;
  my @logs = `ls $folder/$exp*auc`;
  chomp @logs;

  my $first = 1;
  $sum_1_constraints .= "\tc$experements: ";

  foreach my $log(@logs){
    $log =~ s/.*${exp}_(c.*)/$1/;
    next if !(-e "$folder/${exp}_$log");

    my $auc = `grep auc $folder/${exp}_$log`;
    next if $auc eq "";

    $auc =~ s/.*auc = //;
    chomp $auc;

    if(!exists($parameters{$log})){
      $parameters{$log} = scalar(keys %parameters);
      $parameters_inverse[$parameters{$log}] = $log;
    }
    my $value = $auc;

    if($value < 0){
      $value *= -1.0;
      $objective .= " - ";
    }elsif($objective ne "\t"){
      $objective .= " + ";
    }
    $objective .= "$value p4e_${experements}_$parameters{$log} ";

    $sum_1_constraints .= " + " if $first != 1;
    $sum_1_constraints .= "p4e_${experements}_$parameters{$log}";

    $param_exists_constraints .= "\tp${experements}_$parameters{$log}: p4e_${experements}_$parameters{$log} - p_$parameters{$log} <= 0\n";

    $first = 0;
  }

  $sum_1_constraints .= " = 1\n";
}

# output LP to file
open FILE, ">$file" or die("$file: $!\n");
print FILE "Maximize\n$objective\n";
print FILE "Subject to:\n";
print FILE $sum_1_constraints;
print FILE $param_exists_constraints;

print FILE "\tparams: ";
my $first = 1;
for(my $i=0; $i<scalar(keys %parameters); $i++){
  print FILE " + " if $first != 1;
  $first = 0;
  print FILE " p_$i ";
}
print FILE " = $num_params\nBINARY\n";
for(my $i=0; $i<scalar(keys %parameters); $i++){
    print FILE "\tp_$i\n";
}

print FILE "END\n";
close FILE;

# run CPLEX, post process results and print set
my @results = `cplex -c "read $file" "opt" "display solution variables p*"`;
foreach my $line(@results){
  chomp $line;
  if($line =~ /.*p4e_([0-9]*)_([0-9]*).*1.00.*/){
    print "Experement $experement_names[$1]: $parameters_inverse[$2]\n";
  }
  if($line =~ /.*p_([0-9]*).*1.00.*/){
    print "Parameter $parameters_inverse[$1]\n";
  }
}
