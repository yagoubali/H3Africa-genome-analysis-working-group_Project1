## Files to run

> wget -c https://s3.amazonaws.com/gangstr/hg38/genomewide/hg38_ver17.bed.gz

> gzip -d hg38_ver17.bed.gz

> cut -f1 hg38_ver17.bed | sort | uniq
