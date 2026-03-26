#!/bin/bash
# eggd_ctatsplicing


# prefixes all lines of commands written to stdout with datetime
PS4='\000[$(date)]\011'
export TZ=Europe/London

# Exit at any point if there is any error and output each line as it is executed (for debugging)
# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

_download_and_setup() {
    : '''
    Downloads input files, unpacks, set environment variables, and other setup steps
    '''
    mkdir -p /home/dnanexus/genome_lib \
        /home/dnanexus/input \
        /home/dnanexus/out/cancer_introns \
        /home/dnanexus/out/introns \
        /home/dnanexus/out/html_igv_introns \
        /home/dnanexus/out/ctatsplicing_chckpts

    dx-download-all-inputs --parallel

    # Unpack tarred files 
    tar xvzf /home/dnanexus/in/genome_lib/*.tar.gz -C /home/dnanexus/genome_lib

    #Load docker image:
    docker load -i /home/dnanexus/in/ctatsplicing_tar/*.tar.gz
    
    #Set up required environment variables, export to be available to child processes
    export lib_dir \
        docker_image_id \
        ctat_python_cmd \
        sample_name
    
    # Extract CTAT library filename
    lib_dir=$(find /home/dnanexus/genome_lib -type d -name "*" -mindepth 1 -maxdepth 1 | rev | cut -d'/' -f-1 | rev)
    #Extract docker image id:
    docker_image_id=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^trinityctat/ctat_splicing" | cut -d' ' -f2)
    #Extract CTAT tool directory:
    ctat_python_cmd=$(docker run --rm $docker_image_id /bin/bash -c "find /usr/local/src -name STAR_to_cancer_introns.py")
    #Extract Sample Name:
    sample_name=$(ls /home/dnanexus/input/*.star.bam | xargs -n1 basename | awk -F "." '{print $1}')
    
    #Move required files into correct folders:
    ##cancer_splicing.idx:
    mkdir -p /home/dnanexus/genome_lib/${lib_dir}/ctat_genome_lib_build_dir/cancer_splicing_lib
    mv /home/dnanexus/in/cancer_splicing_index/*.idx /home/dnanexus/genome_lib/${lib_dir}/ctat_genome_lib_build_dir/cancer_splicing_lib/cancer_splicing.idx
    ##refGene.bed,refGene.sort.bed.gz, and refGene.sort.bed.gz.tbi :
    mv /home/dnanexus/in/refGene*/refGene.*bed* /home/dnanexus/genome_lib/${lib_dir}/ctat_genome_lib_build_dir/
    
    #Move patient's input files into correct folder:
    mv /home/dnanexus/in/splice_junction/*.SJ.out.tab /home/dnanexus/input/
    mv /home/dnanexus/in/chimeric_junction/*.chimeric.out.junction /home/dnanexus/input/
    mv /home/dnanexus/in/bam/*.star.bam /home/dnanexus/input/
    mv /home/dnanexus/in/bam_index/*.star.bam.bai /home/dnanexus/input/
}

_call_ctatsplicing() {
    : '''
    Run CTAT-Splicing to identify cancer introns in the sample of interest
    '''
    docker run --rm -it \
        -v /home/dnanexus:/data \
        ${docker_image_id} /bin/bash -c "python ${ctat_python_cmd} \
            --SJ_tab_file /data/input/$(ls /home/dnanexus/input/*SJ.out.tab | xargs -n1 basename) \
            --chimJ_file /data/input/$(ls /home/dnanexus/input/*chimeric.out.junction | xargs -n1 basename) \
            --bam_file /data/input/$(ls /home/dnanexus/input/*.star.bam | xargs -n1 basename) \
            --vis \
            --ctat_genome_lib /data/genome_lib/${lib_dir}/ctat_genome_lib_build_dir \
            --output_prefix /data/out/ctatsplicing_full/${sample_name} \
            --sample_name ${sample_name}"
}

_upload_outputs() {
    : '''
    Upload and save outputs
    '''
    mv /home/dnanexus/out/${sample_name}.cancer.introns /home/dnanexus/out/cancer_introns
    mv /home/dnanexus/out/${sample_name}.introns /home/dnanexus/out/introns
    mv /home/dnanexus/out/${sample_name}.ctat-splicing.igv.html /home/dnanexus/out/html_igv_introns
    mv /home/dnanexus/out/${sample_name}.chckpts /home/dnanexus/out/ctatsplicing_chckpts

    dx-upload-all-outputs
}

main() {
    _download_and_setup
    _call_ctatsplicing
    dx-upload-all-outputs
}