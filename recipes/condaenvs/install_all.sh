for file in `ls environments/*-pinned.yml`; do
    echo $file
    conda env create -f $file
done