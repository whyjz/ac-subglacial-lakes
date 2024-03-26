# asp_root=/home/whyjz278/Software/StereoPipeline-3.3.0-Linux/bin
proj4_str='+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +type=crs'
csvformat_str='1:easting 2:northing 3:height_above_datum'
atl06_ref=$1
dem_subsets_folder=$2
dem_processed_folder=$3
bitmask_subsets_folder=$4
projwin_str=$(cat projwin.tmp)

for i in $(ls ${dem_subsets_folder}/*.tif); do
    # i='DEM_subsets/processed-SETSM_s2s041_W2W2_20120419_103001001200B900_1030010013639500_2m_lsf_seg1_dem.tif'
    filename=${i##*/}
    prefix_str=${dem_processed_folder}/asp-${filename%_*}

    pc_align --max-displacement 30 --tif-compress=NONE --save-inv-transformed-reference-points --threads 16 \
             --csv-proj4 "$proj4_str" --csv-format "$csvformat_str" --compute-translation-only \
             $i ${atl06_ref} -o ${prefix_str}

    point2dem ${prefix_str}-trans_reference.tif --nodata-value -9999 -o ${prefix_str} \
              --t_srs "$proj4_str" --dem-spacing 2 --threads 16 --tif-compress None \
              --t_projwin ${projwin_str}

    mv ${prefix_str}-DEM.tif ${prefix_str}_dem.tif
    # cd DEM_subsets
    # ln -sf ../DEMBitmask_subsets/${filename%_*}_bitmask.tif asp-${filename%_*}_bitmask.tif
    # cd ..
done
               
cd ${dem_processed_folder}
for i in $(ls ../${bitmask_subsets_folder#*/}/*bitmask.tif); do
    bitmask_orig_filename=${i##*/}
    ln -sf $i asp-${bitmask_orig_filename}
done
cd ../