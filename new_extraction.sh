#!/bin/bash

# Set the input filenames
genome_dataset="696_genome_dataset.tsv"
rankedlineage="rankedlineage.dmp"
output_tsv="taxa_710_tabl.tsv"

# Header line for the output TSV
echo -e "taxonomy_id\tspecies\tgenus\tfamily\torder\tclass\tphylum\tkingdom" > "$output_tsv"

# Process each organism name in the genome dataset
awk -F'\t' 'NR>1 { print $3 }' "$genome_dataset" | while read -r organism_name; do

    # Trim leading and trailing whitespace from the organism name
    organism_name=$(echo "$organism_name" | sed 's/^ *//;s/ *$//')

    # Use grep to find the organism name in the rankedlineage.dmp file
    grep -F "$organism_name" "$rankedlineage" | sed 's/\t|$//' | awk -F'\t\\|\t' -v org="$organism_name" '
    BEGIN {
        OFS = "\t"  # Set the output field separator to a tab
    }
    {
        # Remove leading and trailing spaces from all fields
        for (i = 1; i <= NF; i++) {
            gsub(/^ +| +$/, "", $i)
        }
        # Check if the second field matches the organism name
        if ($2 == org) {
            # Print the desired columns in the output format
            print $1, $2, $4, $5, $6, $7, $8, $10
        }
    }' >> "$output_tsv"
done

echo "TSV file '$output_tsv' created."
