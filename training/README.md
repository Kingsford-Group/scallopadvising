# Scallop Parameter Advising -- Training

This directory contains 4 (groups of) scripts used to to generate advisor sets.
* `{scallop,stringtie}_coordinate_ascent.pl` which can be used to find an optimal parameter choice for a given training example,
* `{scallop,stringtie}_generate_config_from_working_dir.pl` parses the output from coordinate ascent to generate a configuration file,
* `{scallop,stringtie}_run_with_config.pl` runs an assembly of an experiment with a given configuration, and
* `advisor_subset.pl` which can be used to find subsets of parameter choices for low resource environments.

## Basic Workflow

```
foreach example e:
  ./scallop_coordinate_ascent.pl e {e}_output/
  ./scallop_generate_config_from_working_dir.pl {e}_output/ configs/{e}.config

foreach example e:
  foreach example p: #use the parameter this time
    ./scallop_run_with_config.pl e configs/{p}.config out/{e}_c{p}

./advisor_subset.pl out/ temp.lp 10
```
