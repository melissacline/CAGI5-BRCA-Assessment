## CAGI5-BRCA-Assessment

The assessment can be repeated with the following steps:


1. Download the data files from CAGI.  Make the src and data subdirectories.
Create the ../data/actual and ../data/prediction subdirectories.  Copy
the ENIGMA file CAGI_megamultifac_2018-06-01.txt into actual.  Copy the 
prediction files into ../data/prediction.

2. Use these commands to build the file ../data/actual/variant.summary.txt.
Import into Google sheets.  Label the domains by hand.  Build a pivot table
to serve as Table 1 from the paper. 
```
cut -f1,3,4 ../data/predictions.merged.txt |tail -n +2 |awk '{ntokens = split($1,tokens,  ":c."); split(tokens[2], subtokens, "[ACGT_]"); print tokens[1] "\t" subtokens[1] "\t" $2 "\t" $3}' |sort -n -k2  |grep BRCA1  > ../data/actual/variant.summary.txt
cut -f1,3,4 ../data/predictions.merged.txt |tail -n +2 |awk '{ntokens = split($1,tokens,  ":c."); split(tokens[2], subtokens, "[ACGT_]"); print tokens[1] "\t" subtokens[1] "\t" $2 "\t" $3}' |sort -n -k2  |grep BRCA2  >> ../data/actual/variant.summary.txt
```

3. Create the subdirectory ../data/vep_raw.  Create the file vep_input.txt, 
which contains the cDNA HGVS representation of each variant.  Use the 
canonical RefSeq transcripts NM_007294.3 for BRCA1 and NM_000059.3 for BRCA2.
The nucleotide HGVS suffix is in the ENIGMA data.  Run VEP (online) with 
vep_raw/vep_input.txt, generating vep_raw/vep_output.txt.  Preprocess 
as shown, to add VEP as a new "predictor"
```
vep_preprocess.bash
```
 
4. Merge the actual clinical signficance and predictions
```
mergeData.py > ../data/predictions.merged.txt
```
