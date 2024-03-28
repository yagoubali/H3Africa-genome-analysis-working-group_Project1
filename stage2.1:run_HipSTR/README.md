> Files to run

> wget -c https://github.com/HipSTR-Tool/HipSTR-references/raw/master/human/GRCh38.hipstr_reference.bed.gz

> gzip -d GRCh38.hipstr_reference.bed.gz

> sed -i -e 's/^/chr/' GRCh38.hipstr_reference.bed

> cut -f1 GRCh38.hipstr_reference.bed | sort | uniq
