#!/usr/bin/env bash
#
# These commands were used to preprocess the VEP output in data/vep_raw,
# which contains SIFT, PolyPhen and Revel predictions on the CAGI targets.
# See Readme.md for further information on the data provenance.
#

#
# Select the SIFT, PolyPhen and Revel scores for the canonical transcripts.
# VEP denotes missing values with '-'.  Replace them with NA.
cat ../data/vep_raw/vep_output.txt | awk -F'\t' '{ 
    split($1, tokens, ":"); 
    if (NR == 1 || $9 == "NM_000059.3" || $9 == "NM_007294.3") { 
        print tokens[2] "\t" $6 "\t" $32 "\t" $33 "\t" $38 
    }
}' |sed 's/-/NA/g' > ../data/vep_raw/vep_subset.txt 

#
# Create a 'prediction' directory
mkdir ../data/prediction/VEP

#
# Generate 'prediction' files for each of the three predictors
( echo -e "DNA\tGene\tVariant\tP\tSD"; \
  tail -n +2 ../data/vep_raw/vep_subset.txt \
  | awk  '{ print $1 "\t" $2 "\t" $1 "\t" $3 "\t0" }' ) \
> ../data/prediction/VEP/sift.tx
( echo -e "DNA\tGene\tVariant\tP\tSD"; \
  tail -n +2 ../data/vep_raw/vep_subset.txt \
  | awk  '{ print $1 "\t" $2 "\t" $1 "\t" $4 "\t0" }' ) \
> ../data/prediction/VEP/polyphen.txt
( echo -e "DNA\tGene\tVariant\tP\tSD"; \
  tail -n +2 ../data/vep_raw/vep_subset.txt \
  | awk  '{ print $1 "\t" $2 "\t" $1 "\t" $5 "\t0" }' ) \
> ../data/prediction/VEP/revel.txt