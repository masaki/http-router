#!/bin/sh
rm -f nytprof.out
rm -rf nytprof
perl -d:NYTProf -S tools/profile.pl --loop 200
nytprofhtml -f nytprof.out
open nytprof/index.html

