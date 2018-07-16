#!/usr/bin/perl
use strict;
use warnings;

my $folder = shift;
my $file = shift;
my @coef = split(/,/,shift);
my $num_params = shift;

my $objective = "\t";
my $sum_1_constraints = "";
my $param_exists_constraints = "";

my $experements = -1;
my @experement_names;
my %parameters;
my @parameters_inverse;

foreach my $exp(`ls $folder/*auc | sed "s/.*\\/\\(.*\\)_c.*/\\1/" | sort -u`){
  chomp $exp;
  next if `grep auc $folder/$exp*auc | wc -l` < 31;
  print STDERR "Reading $exp\r";
  push(@experement_names,$exp);
  $experements++;
  my @logs = `ls $folder/$exp*log`;
  chomp @logs;

  my $first = 1;
  $sum_1_constraints .= "\tc$experements: ";

  foreach my $log(@logs){
    $log =~ s/.*${exp}_(c.*)/$1/;
    #print STDERR "Processing $log\r";

    my $auc_fname = $log;
    $auc_fname =~ s/.log/.auc/;
    next if !(-e "$folder/${exp}_$auc_fname");

    my $auc = `grep auc $folder/${exp}_$auc_fname`;
    my $sensitivity = $auc;
    next if $auc eq "";

    $sensitivity =~ s/.*sensitivity = ([0-9\.e]*).*/$1/;
    $auc =~ s/.*auc = //;
    chomp $auc;
    #print "${exp}_$auc_fname: $auc\n";

    if(!exists($parameters{$log})){
      $parameters{$log} = scalar(keys %parameters);
      $parameters_inverse[$parameters{$log}] = $log;
    }
    my $value = 0;
    my @mappings = split(/\s+/,`grep Mapped $folder/${exp}_$log`);
    ###next if scalar(@mappings) < 12;
    #    0      1         2              3              4                  5    6                7                8              9               10     11      12
    # Mapped counts:  327745278       78896749        0.240726        1025424 0.00312872      128901319       391580670       170714778       20397.9 125770  34733
    ###$value += 1.0 * $coef[0] * $mappings[2] / (1.0 * $mappings[8] ) if $mappings[8] != 0;
    ###$value += 1.0 * $coef[1] * $mappings[7] / (1.0 * $mappings[9] ) if $mappings[9] != 0;
    ###$value += 1.0 * $coef[2] * $mappings[10]/ (1.0 * $mappings[12]) if $mappings[12]!= 0;
    ###$value += 1.0 * $coef[3] * $mappings[11]/ (1.0 * $mappings[12]) if $mappings[12]!= 0;
    $value += 1.0 * $coef[4] * $auc if scalar(@coef)>=5;

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
