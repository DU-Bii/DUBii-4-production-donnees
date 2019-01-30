mkdir DuBii-4.2
cd DuBii-4.2

mkdir -p DATA/raw

# Télécharchement des séquences
#fastq-dump  --split-files --gzip SRR8082143
wget -P DATA/raw/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR808/003/SRR8082143/SRR8082143_1.fastq.gz
wget -P DATA/raw/ ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR808/003/SRR8082143/SRR8082143_2.fastq.gz

# Controle qualité des sequences brutes
mkdir -p report/fastqc/
fastqc -o report/fastqc/ DATA/raw/SRR8082143_*.fastq.gz 
multiqc -d report/fastqc/ -o multiqc/ -n raw_multiqc

# Preprocess 
mkdir -p DATA/trim/
cutadapt -a CTGTCTCTTATACACATCT -A AGATGTGTATAAGAGACAG -o DATA/trim/K12_trim_R1.fastq.gz -p DATA/trim/K12_trim_R2.fastq.gz DATA/raw/SRR8082143_1.fastq.gz DATA/raw/SRR8082143_2.fastq.gz > report/cutadapt.log
mkdir -p DATA/clean/
sickle pe –q 20 –l 50 –n --gzip-output -f DATA/trim/K12_trim_R1.fastq.gz -r DATA/trim/K12_trim_R2.fastq.gz -t sanger -o DATA/clean/K12_clean_R1.fastq.gz -p DATA/clean/K12_clean_R2.fastq.gz -s DATA/clean/K12_clean_solo.fastq.gz > report/sickle.log

# Controle qualité des sequences post-preprocess
fastqc -o report/fastqc/ DATA/clean/K12_clean_*.fastq.gz
multiqc -d report/fastqc/ -o multiqc/ -n clean_multiqc

# FastP
mkdir -p DATA/fastp/
fastp -i DATA/raw/SRR8082143_1.fastq.gz -I DATA/raw/SRR8082143_2.fastq.gz -o DATA/fastp/K12_fastp_R1.fastq.gz -O DATA/fastp/K12_fastp_R2.fastq.gz -l 50 -q 20 --html report/fastp.html --json report/fastp.json

# MultiQC : fastqc + cutadapt + fastp
multiqc report/ -o multiqc/ -n global_multiqc
