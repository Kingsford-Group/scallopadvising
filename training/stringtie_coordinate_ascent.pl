#!/usr/bin/perl
use strict;
use warnings;
use threads;
use threads::shared;
use Data::Dumper;

our $working_dir = shift;
chomp $working_dir;

our $experement_file = shift;
chomp $experement_file;

my $old_working_dir = "";
my $old_working_dir_in = shift;
$old_working_dir = $old_working_dir_in if defined($old_working_dir_in);
chomp $old_working_dir;

my $num_threads = 3;
my $in_threads = shift; 
$num_threads = $in_threads if $in_threads ne "";

our %parameter_values = (
  "f" => 0.1,
  "m" => 200,
  "a" => 10,
  "j" => 1,
  "t" => 0, #true/false
  #"c" => 2.5,
  "g" => 50,
  "M" => 0.95,
  "u" => 0 #true/false
);

our %step_size = (
  "f" => 50.0,
  "m" => 10000,
  "a" => 1000,
  "j" => 100,
  "t" => 0, #true/false
  #"c" => 200.0,
  "g" => 5000,
  "M" => 50.0,
  "u" => 1 #true/false
);

our %type = (
  "f" => "float",
  "m" => "int",
  "a" => "int",
  "j" => "int",
  "t" => "bool", #true/false
  #"c" => "float",
  "g" => "int",
  "M" => "float",
  "u" => "bool" #true/false
);

sub run_with_one_change{
  my $param_to_change = shift;
  my $param_value = shift;
  my $check = "";
  $check = shift;

  my $command = "stringtie $experement_file -c 0.001 ";
  my $out_fname = "";
  return 0 if($param_value ne "" && (($type{$param_to_change} eq "bool" && $param_value > 1) || $param_value < 0));

  if($type{$param_to_change} eq "float"){
    #print "$param_value -> ";
    $param_value = sprintf("%.2f", $param_value);
    #print " $param_value\n";
  }
  
  for my $p (sort keys(%type)){
    if($p ne $param_to_change){
      if($type{$p} ne "bool"){
        $command .= " -$p $parameter_values{$p} ";
      }else{
        $command .= " -$p " if $parameter_values{$p}==1 ;
      }
      $out_fname .= "_$parameter_values{$p}";
    }else{
        if($type{$p} ne "bool"){
          $command .= " -$p $param_value ";
        }else{
          $command .= " -$p " if ($param_value==1);
        }
        $out_fname .= "_$param_value";
    }
  }
  my $auc = "";
  #print STDERR "Would run '$command'\n";
  #return 0;
  system("mkdir -p $working_dir");

  if(-e "$working_dir/$out_fname.auc" && `grep -c auc $working_dir/$out_fname.auc` > 0){
    $auc = `cat $working_dir/$out_fname.auc`;
  }elsif($old_working_dir ne "" && -e "$old_working_dir/$out_fname.auc" && `grep -c auc $old_working_dir/$out_fname.auc` > 0){
    system("cp $old_working_dir/$out_fname* $working_dir/");
    $auc = `cat $working_dir/$out_fname.auc`;
  }else{
    return 0 if $check eq "check";
    #print $command."\n";
    #exit(0);
    system("gunzip $working_dir/$out_fname.gtf.gz") if(-e "$working_dir/$out_fname.gtf.gz");
    #print "$command -o $working_dir/$out_fname.gtf >/dev/null 2>&1\n" if(!(-e "$working_dir/$out_fname.gtf"));
    system("$command -o $working_dir/$out_fname.gtf ") if(!(-e "$working_dir/$out_fname.gtf"));
    if((-e "$working_dir/$out_fname.gtf")){
      if(`grep -c "^chr" $working_dir/$out_fname.gtf` == 0){
        system("sed -i 's/^/chr/' $working_dir/$out_fname.gtf");
      }

      system("gffcompare -r data/GRCh38_chr.gtf -o $working_dir/$out_fname $working_dir/$out_fname.gtf");
      if((-e "$working_dir/$out_fname.$out_fname.gtf.tmap")){
        $auc = `/mnt/disk44/user/mingfus/data/repositories/rnaseqtools/gtfcuff/gtfcuff auc $working_dir/$out_fname.$out_fname.gtf.tmap 170378 | tee $working_dir/$out_fname.auc`;
        system("rm $working_dir/$out_fname.$out_fname.gtf.refmap $working_dir/$out_fname.loci $working_dir/$out_fname.annotated.gtf $working_dir/$out_fname.tracking");
        system("gzip $working_dir/$out_fname.gtf");
      }else{
        return 0;
      }
    }else{
      return 0;
    }
  }
  return 1 if $check eq "check";
  chomp $auc;
  $auc =~ s/.*auc = //;
  return $auc;
}

my $cur_auc = run_with_one_change("","","");

my $decreased_steps = 1;
while($decreased_steps == 1){
  $decreased_steps = 0;
  my $made_one_change = 1;
  while($made_one_change == 1){
    $made_one_change = 0;
    foreach my $param(sort keys(%type)){
      print("$cur_auc\n");
      my $single_param_change = 1;
      while($single_param_change==1){
        $single_param_change = 0;
        print STDERR "Updating $param, type: ". $type{$param} ."\n";
        if($type{$param} ne "bool"){
          my @threads;
          my @threads_index;
          my @nothreads;
          my @nothreads_index;
          foreach my $t(1...$num_threads){
            if(run_with_one_change($param, $parameter_values{$param} + ($t * $step_size{$param}),"check") == 0){
              push @threads, threads->new (sub { return run_with_one_change($param, $parameter_values{$param} + ($t * $step_size{$param}),""); } );
              push @threads_index, $t;
            }
            else{
              push @nothreads, run_with_one_change($param, $parameter_values{$param} + ($t * $step_size{$param}),"");
              push @nothreads_index, $t;
            }
          }
          foreach my $t(1...$num_threads){
            if(run_with_one_change($param, $parameter_values{$param} - ($t * $step_size{$param}),"check") == 0){
              push @threads, threads->new (sub { run_with_one_change($param, $parameter_values{$param} - ($t * $step_size{$param}),""); } );
              push @threads_index, -1 * $t;
            }else{
              push @nothreads, run_with_one_change($param, $parameter_values{$param} - ($t * $step_size{$param}),"");
              push @nothreads_index, -1 * $t;
            }
          }
          print STDERR "Num threads running: " . scalar(@threads) . "\n";
          my $max_change = 0;
          foreach my $t (0...scalar(@threads)-1){
          	my $in_auc = $threads[$t]->join();
            if($in_auc > $cur_auc){
              $cur_auc = $in_auc;
              $max_change = $threads_index[$t];
              #$max_change = ($t >= $num_threads)?$num_threads - $t - 1: $t + 1;
              $single_param_change = 1;
              $made_one_change = 1;
            }
          }
          foreach my $nt (0...scalar(@nothreads)-1){
            my $in_auc = $nothreads[$nt];
            if($in_auc > $cur_auc || ($in_auc == $cur_auc && abs($max_change) > abs($nothreads_index[$nt]))){
              $cur_auc = $in_auc;
              $max_change = $nothreads_index[$nt];
              #$max_change = ($t >= $num_threads)?$num_threads - $t - 1: $t + 1;
              $single_param_change = 1;
              $made_one_change = 1;
            }
          }
          $parameter_values{$param} += $max_change * $step_size{$param};
          #exit(0);
        }else{
          my $auc_plus = run_with_one_change($param, $parameter_values{$param} + $step_size{$param},"");
          if($auc_plus > $cur_auc){
            $cur_auc = $auc_plus;
            $parameter_values{$param} += $step_size{$param};
            $single_param_change = 1;
            $made_one_change = 1;
          }else{
            my $auc_minus = run_with_one_change($param, $parameter_values{$param} - $step_size{$param},"");
            if($auc_minus > $cur_auc){
              $cur_auc = $auc_minus;
              $parameter_values{$param} -= $step_size{$param};
              $single_param_change = 1;
              $made_one_change = 1;
            }
          }
        }
      }
    }
  }
  foreach my $param(sort keys(%type)){
    if($type{$param} eq "int" ){
      my $temp = int($step_size{$param} * 0.75);
      $temp = ($temp < $step_size{$param} - 1)?$temp:$step_size{$param} - 1;
      if($temp > 0){
        $step_size{$param} = $temp;
        $decreased_steps = 1;
      }
    }

    if($type{$param} eq "float"){
      my $temp = sprintf "%.2f", $step_size{$param} * 0.75;
      $temp = ($temp < $step_size{$param} - 0.01)?$temp:$step_size{$param} - 0.01;
      if($temp > 0){
        $step_size{$param} = $temp;
        $decreased_steps = 1;
      }
    }
  }
  print Dumper(\%step_size);
}
