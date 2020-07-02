#!/bin/bash
# Longitudinal Automatic Segmentation of Hippocampus Subfields (LASHiS).
#
# Adapted from the ANTs Longitudinal Cortical Thickness pipeline https://github.com/ANTsX/ANTs/
# and stats export from ASHS https://sites.google.com/site/hipposubfields/home
# Requires ANTs and ASHS
# Requires ASHS compatible manually labelled atlas (available at ASHS website).
# Thomas Shaw 1/5/2019
# Language:  BASH Shell Script
# Copyright (c) 2019 Thomas B Shaw
#  
# 
#
# LASHiS is free software. Its composite parts are freely available.
# You can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Check dependencies

PROGRAM_DEPENDENCIES=( 'antsApplyTransforms' 'N4BiasFieldCorrection' )
SCRIPT_DEPENDENCIES=( 'antsBrainExtraction.sh' 'antsMultivariateTemplateConstruction2.sh' 'antsJointLabelFusion2.sh' )
ASHS_DEPENDENCIES=( '/bin/ashs_main.sh' '/ext/Linux/bin/c3d' )

for D in ${PROGRAM_DEPENDENCIES[@]};
do
    if [[ ! -s ${ANTSPATH}/${D} ]];
    then
        echo "Error:  we can't find the $D program."
        echo "Perhaps you need to \(re\)define \$ANTSPATH in your environment."
        exit
    fi
done

for D in ${SCRIPT_DEPENDENCIES[@]};
do
    if [[ ! -s ${ANTSPATH}/${D} ]];
    then
        echo "We can't find the $D script."
        echo "Perhaps you need to \(re\)define \$ANTSPATH in your environment."
        exit
    fi
done
for D in ${ASHS_DEPENDENCIES[@]};
do
    if [[ ! ${ASHS_ROOT}/bin/${D} ]];
    then
        echo "We can't find $D in the ASHS directory ."
        echo "Perhaps you need to \(re\)define \$ASHS_ROOT in your environment."
        exit
    fi
done
function Usage {
    cat <<USAGE

`basename $0` performs a longitudinal estimation of hippoocampus subfields.  The following steps are performed:
  1. Run Cross-sectional ASHS on all timepoints
  2. Create a single-subject template (SST) from all the data, then cross-sectionally run the SST through ASHS.
  3. Using the Cross-sectional inputs as priors, label the hippocampi of the SST.
  4. Segmentation results are reverse normalised to the individual time-point. 

# Environment Variables:
  ASHS_ROOT         Path to the ASHS root directory
  ANTSPATH          Path to the ANTs root directory

Misc Notes:
  The ASHS_TSE image slice direction should be z. In other words, the dimension
  of ASHS_TSE image should be 400x400x30 or something like that, not 400x30x400


Usage:

`basename $0` -a atlas selection for ashs
              <OPTARGS>
              -o outputPrefix
              \${anatomicalImages[@]}

Example:

  bash $0 -a /some/path/ashs_atlas_umcutrecht_7t_20170810/ -o output \${anatomicalImages[@]}

Required arguments:
	-o:  Output prefix   	The following subdirectory and images are created for the single-subject template
            			{OUTPUT_PREFIX}SingleSubjectTemplate/
                		{OUTPUT_PREFIX}SingleSubjectTemplate/T_template*.nii.gz
	-a: Atlas selection	Full path for the atlas you would like to use for the Cross-sectional
                                labelling of ASHS and the SST. Can be made in ASHS_train
			  
	anatomical images	Set of multimodal (T1w or gradient echo, followed by T2w FSE/TSE input)
                                data. Data must be in the format specified by ASHS & ordered as follows:
                                {time1_T1w} {time1_T2w} \                          
                                {time1_T2w} {time2_T2w} \
                                           .
                                           .
                                {timeN_T1w} {timeN_T2w} ...
				 
	Optional arguments:

	-s:  image file suffix	Any of the standard ITK IO formats e.g. nrrd, nii.gz (default), mhd
	-c:  control type	Control for parallel computation for ANTs steps
                    		(JLF,SST creation)  (default 0):
                                0 = run serially
                                1 = SGE qsub
                                2 = use PEXEC (localhost) (remember to define cores in -j)
                                3 = Apple XGrid
                                4 = PBS qsub
                                5 = SLURM
	-d:  OPTS               Pass in additional options to SGEs qsub for ASHS. Requires "-c 1"
	-e:  ASHS file          ProConfiguration file. If not passed, uses $ASHS_ROOT/bin/ashs_config.sh 
	-f:  Diet LASHiS        Diet LASHiS (reverse normalise the SST only) then exit.
	-g:  denoise anatomical images	
				Denoise anatomical (both T1w and TSE) images (default = 0).
	-j:  number of cpu cores
				Number of cpu cores to use locally for pexec option 
                                (default 2; requires "-c 2")                                        
	-n:  N4 Bias Correction
				If yes, Bias correct the input images before template creation.
                                0 = No
                                1 = Yes
	-b:  keep temporary files
				Keep brain extraction/segmentation warps, etc (default = 0).
				
				
Basic usage: LASHiS.sh -a /path/to/atlas
             	 <OPTARGS>
             	 -o outputPrefix
             	 {anatomicalImages}
USAGE
    exit 1
}

echoParameters() {
    cat <<PARAMETERS

    Using LASHiS with the following arguments:
      image dimension         = ${DIMENSION}
      anatomical image        = ${ANATOMICAL_IMAGES[@]}
      output prefix           = ${OUTPUT_PREFIX}
           
    Other parameters:
      run quick               = ${RUN_QUICK}
      debug mode              = ${DEBUG_MODE}
      float precision         = ${USE_FLOAT_PRECISION}
      denoise                 = ${DENOISE}
      number of cores         = ${CORES}
      control type            = ${DOQSUB}
      N4 Bias Correction      = ${N4_BIAS_CORRECTION}
      SGE script for ASHS     = ${ASHS_SGE_OPTS}
      ASHS config file        = ${ASHS_CONFIG}
      Diet LASHiS             = ${DIET_LASHIS}
PARAMETERS
}

# Echos a command to stdout, then runs it
# Will immediately exit on error unless you set debug flag here
DEBUG_MODE=0

function logCmd() {
    cmd="$*"
    echo "Start command:"
    echo $cmd
    $cmd

    cmdExit=$?

    if [[ $cmdExit -gt 0 ]];
    then
	echo "ERROR: command exited with nonzero status $cmdExit"
	echo "Command: $cmd"
	echo
	if [[ ! $DEBUG_MODE -gt 0 ]];
        then
            exit 1
        fi
    fi

    echo "Command finished without error!"
    echo
    echo

    return $cmdExit
}

################################################################################
#
# Main routine
#
################################################################################

HOSTNAME=`hostname`
DATE=`date`

CURRENT_DIR=`pwd`/
OUTPUT_DIR=${CURRENT_DIR}/tmp$RANDOM/
OUTPUT_PREFIX=${OUTPUT_DIR}/tmp
OUTPUT_SUFFIX="nii.gz"

DIMENSION=3

NUMBER_OF_MODALITIES=2

ANATOMICAL_IMAGES=()
RUN_QUICK=0
USE_RANDOM_SEEDING=1


USE_SST_CORTICAL_THICKNESS_PRIOR=0
REGISTRATION_TEMPLATE=""
DO_REGISTRATION_TO_TEMPLATE=0
DENOISE=0
N4_BIAS_CORRECTION=0
DIET_LASHIS=0

DOQSUB=0
CORES=2


################################################################################
#
# Programs and their parameters
#
################################################################################

USE_FLOAT_PRECISION=0
KEEP_TMP_IMAGES=0

if [[ $# -lt 3 ]] ; then
    Usage >&2
    exit 1
else
    while getopts "a:b:c:d:e:f:g:h:j:k:l:m:n:o:p:q:r:s:t:u:v:x:w:y:z:" OPT
    do
	case $OPT in
            a)  #ASHS_atlas directory
		ASHS_ATLAS=$OPTARG
		if [[ ! -d $ASHS_ATLAS ]];
		then
		    echo "You must specify the full path to the ASHS atlas directory"
		    exit 1
		fi
	        ;;
	    b)
		KEEP_TMP_IMAGES=$OPTARG
		;;
            c) # QSUBOPTS
		DOQSUB=$OPTARG
		if [[ $DOQSUB -gt 5 ]];
		then
		    echo " DOQSUB must be an integer value (0=serial, 1=SGE qsub, 2=try pexec, 3=XGrid, 4=PBS qsub, 5=SLURM ) you passed  -c $DOQSUB "
		    exit 1
		fi
		;;
	    d) #ASHS SGE options
		ASHS_SGE_OPTS="-q $OPTARG"
		;;
	    e) #ASHS Config file
		ASHS_CONFIG="-C $OPTARG"
		;;
	    f) #Diet LASHiS
		DIET_LASHIS=$OPTARG
		;;
            g) #denoise
		DENOISE=$OPTARG
		;;
	    n) #N4
		N4_BIAS_CORRECTION=$OPTARG
		;;
            h) #help
		Usage >&2
		exit 0
		;;
            j) #number of cpu cores to use (default = 2)
		CORES=$OPTARG
		openmp_variable=$OPTARG
		;;
            o) #output prefix
		OUTPUT_PREFIX=$OPTARG
		;;
            q) # run quick
		RUN_QUICK=$OPTARG
		;;
	    z) #debug mode
		DEBUG_MODE=$OPTARG
		;;
            *) # getopts issues an error message
		echo "ERROR:  unrecognized option -$OPT $OPTARG"
		exit 1
		;;
	esac
    done
fi

if [[ ${DOQSUB} == '1' ]] ;
then ASHS_QSUBOPTS="-Q"
elif [[ ${DOQSUB} == '2' ]]; then
    export OMP_NUM_THREADS=$openmp_variable ;     
else ASHS_QSUBOPTS=""  ;
fi


# Shiftsize is calculated because a variable amount of arguments can be used on the command line.
# The shiftsize variable will give the correct number of arguments to skip. Issuing shift $shiftsize will
# result in skipping that number of arguments on the command line, so that only the input images remain.
shiftsize=$(($OPTIND - 1))
shift $shiftsize
# The invocation of $* will now read all remaining arguments into the variable IMAGESETVARIABLE
IMAGESETVARIABLE=$*
NINFILES=$(($nargs - $shiftsize))
IMAGESETARRAY=()

for IMG in $IMAGESETVARIABLE
do
    ANATOMICAL_IMAGES[${#ANATOMICAL_IMAGES[@]}]=$IMG
done
if [[ ${#ANATOMICAL_IMAGES[@]} -eq 0 ]];
then
    echo "Error:  no anatomical images specified."
    exit 1
fi
echo "###########################################################################################"
echo " Performing LASHiS cross-sectional using the following ${NUMBER_OF_MODALITIES}-tuples:  "
echo "###########################################################################################"
for (( i = 0; i < ${#ANATOMICAL_IMAGES[@]}; i+=${NUMBER_OF_MODALITIES} ))
do
    IMAGEMETRICSET=""
    for (( j = 0; j < $ANATOMICAL_IMAGES; j++ ))
    do
        k=0
        let k=${i}+${j}
        IMAGEMETRICSET="$IMAGEMETRICSET ${ANATOMICAL_IMAGES[$k]}"
    done
    echo ${IMAGEMETRICSET}
    echo ${ANATOMICAL_IMAGES[@]}
    
done
echo "###########################################################################################"


#DIET LASHiS and fast parameters.
# 0 - Fast SST (old ANTS) but everything else slower for quality
# 1 - + FAST JLF
# 2 - + Diet LASHiS
RUN_OLD_ANTS_SST_CREATION=1
RUN_ANTSCT_TO_SST_QUICK=0
RUN_FAST_MALF_COOKING=0
RUN_FAST_ANTSCT_TO_GROUP_TEMPLATE=0

if [[ $RUN_QUICK -gt 0 ]];
then
    RUN_ANTSCT_TO_SST_QUICK=1
fi

if [[ $RUN_QUICK -gt 1 ]];
then
    RUN_FAST_JLF=1
fi

if [[ $RUN_QUICK -gt 2 ]];
then
    RUN_DIET=1
fi

################################################################################
#
# Preliminaries:
#  1. Check existence of inputs
#  2. Figure out output directory and mkdir if necessary
#
################################################################################

for (( i = 0; i < ${#ANATOMICAL_IMAGES[@]}; i++ ))
do
    if [[ ! -f ${ANATOMICAL_IMAGES[$i]} ]];
    then
	echo "The specified image \"${ANATOMICAL_IMAGES[$i]}\" does not exist."
	exit 1
    fi
done

OUTPUT_DIR=${OUTPUT_PREFIX%\/*}
if [[ ! -d $OUTPUT_DIR ]];
then
    echo "The output directory \"$OUTPUT_DIR\" does not exist. Making it."
    mkdir -p $OUTPUT_DIR
fi

echoParameters >&2

echo "---------------------  Running `basename $0` on $HOSTNAME  ---------------------"

time_start=`date +%s`

################################################################################
#
# Single-subject template creation
#
################################################################################
##########################
##  Do denoising if on  ##
##########################

if [[ ${DENOISE} == 1 ]] ; then
    echo
    echo "###########################################################################################"
    echo " Denoising                                                                                 "
    echo "###########################################################################################"
    echo
    DENOISED_ANATOMICAL_IMAGES=''
    for (( i=0; i < ${#ANATOMICAL_IMAGES[@]}; i++ )) 
    do
	if [[ ! -e ${ANATOMICAL_IMAGES[$i]:0:-7}_denoised.nii.gz ]] ; then 
	BASENAME_ID=`basename ${ANATOMICAL_IMAGES[$i]}`
	BASENAME_ID=${BASENAME_ID/\.nii\.gz/}
	BASENAME_ID=${BASENAME_ID/\.nii/}
	logCmd ${ANTSPATH}/DenoiseImage \
	       -d 3 \
	       -i ${ANATOMICAL_IMAGES[$i]} \
	       -o ${ANATOMICAL_IMAGES[$i]:0:-7}_denoised.nii.gz \
	       -n Rician \
	       -v
	fi
	DENOISED_ANATOMICAL_IMAGES="${DENOISED_ANATOMICAL_IMAGES}"' '"${ANATOMICAL_IMAGES[$i]:0:-7}_denoised.nii.gz"
    done
    unset ANATOMICAL_IMAGES
    #ANATOMICAL_IMAGES=${DENOISED_ANATOMICAL_IMAGES}
    
    for IMG in $DENOISED_ANATOMICAL_IMAGES
    do
	ANATOMICAL_IMAGES[${#ANATOMICAL_IMAGES[@]}]=$IMG
    done
    echo  "new anat images are: ${ANATOMICAL_IMAGES[@]}"
fi
echo 
echo
echo "###########################################################################################"
echo " Creating single-subject template                                                          "
echo "###########################################################################################"
echo
TEMPLATE_MODALITY_WEIGHT_VECTOR='1'
for(( i=1; i < 2 ; i++ ))
do
    TEMPLATE_MODALITY_WEIGHT_VECTOR="${TEMPLATE_MODALITY_WEIGHT_VECTOR}x1"
done
TEMPLATE_Z_IMAGES=''

OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE="${OUTPUT_PREFIX}SingleSubjectTemplate/"

logCmd mkdir -p ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}
SINGLE_SUBJECT_TEMPLATE=${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template0.nii.gz
# Pad initial template image to avoid problems with SST drifting out of FOV
if [[ ! -f ${SINGLE_SUBJECT_TEMPLATE} ]]; then
    for(( i=0; i < 2 ; i++ ))
    do
	TEMPLATE_INPUT_IMAGE="${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}initTemplateModality${i}.nii.gz"

	logCmd ${ANTSPATH}/ImageMath 3 ${TEMPLATE_INPUT_IMAGE} PadImage ${ANATOMICAL_IMAGES[$i]} 5

	TEMPLATE_Z_IMAGES="${TEMPLATE_Z_IMAGES} -z ${TEMPLATE_INPUT_IMAGE}"
    done
fi
time_start_sst_creation=`date +%s`

if [[ ! -f $SINGLE_SUBJECT_TEMPLATE ]];
then
    logCmd ${ANTSPATH}/antsMultivariateTemplateConstruction.sh \
           -d 3 \
           -o ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_ \
           -b 0 \
           -g 0.25 \
           -i 4 \
           -c ${DOQSUB} \
           -j ${CORES} \
           -k 2 \
           -w ${TEMPLATE_MODALITY_WEIGHT_VECTOR} \
           -m 100x70x30x3 \
           -n ${N4_BIAS_CORRECTION} \
           -r 1 \
           -s CC \
           -t GR \
	   -y 1 \
           ${TEMPLATE_Z_IMAGES} \
	   ${ANATOMICAL_IMAGES[@]}  
fi

if [[ ! -f ${SINGLE_SUBJECT_TEMPLATE} ]];
then
    echo "Error:  The single subject template was not created.  Exiting."
    exit 1
fi
SINGLE_SUBJECT_TEMPLATE=${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template0_rescaled.nii.gz
if [[ ! -f ${SINGLE_SUBJECT_TEMPLATE} ]]; then 
    #Rescale the images because ASHS can't handle float for some reason
    logCmd ${ANTSPATH}/ImageMath 3 ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template1_rescaled.nii.gz RescaleImage ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template1.nii.gz 0 1000
    logCmd ${ANTSPATH}/ImageMath 3 ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template0_rescaled.nii.gz RescaleImage ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template0.nii.gz 0 1000
    
fi
###############################
##  Label the SST with ASHS  ##
###############################
if [[ ! -e ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}SST_ASHS/final/SST_ASHS_right_heur_volumes.txt ]] ;
then
    logCmd ${ASHS_ROOT}/bin/ashs_main.sh \
	   -a ${ASHS_ATLAS} \
	   -g ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/T_template0_rescaled.nii.gz \
	   -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/T_template1_rescaled.nii.gz \
	   -w ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS \
	   ${ASHS_QSUBOPTS} \
	   -T \
	   ${ASHS_CONFIG} \
	   ${ASHS_SGE_OPTS}
fi
#CLEAN UP

logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}job*.sh
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}job*.txt
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}rigid*
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}*Repaired*
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}*WarpedToTemplate*
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template0warp.nii.gz
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_template0Affine.txt
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}T_templatewarplog.txt
logCmd rm -f ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}initTemplateModality*.nii.gz


logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/affine_t1_to_template
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/ants_t1_to_temp
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/bootstrap
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/dump
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/flirt_t2_to_t1
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/mprage_raw.nii.gz
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/tse_raw.nii.gz
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/mprage_to_chunk*
logCmd rm -rf ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/*regmask


time_end_sst_creation=`date +%s`
time_elapsed_sst_creation=$((time_end_sst_creation - time_start_sst_creation))

echo
echo "###########################################################################################"
echo " Done with single subject template:  $(( time_elapsed_sst_creation / 3600 ))h $(( time_elapsed_sst_creation %3600 / 60 ))m $(( time_elapsed_sst_creation % 60 ))s"
echo "###########################################################################################"
echo

################################################################################
#
#  DIET LASHiS
#
################################################################################

if [[ ${DIET_LASHIS} == 1 ]] ;
then
    echo
    echo "###########################################################################################"
    echo "   DIET LASHiS                                              "
    echo "###########################################################################################"
    echo
    time_start_DL=`date +%s`
    #first get the labels ready
    OUTPUT_DIRECTORY_FOR_DL=${OUTPUT_DIR}/Diet_LASHiS
    logCmd mkdir -p ${OUTPUT_DIRECTORY_FOR_DL}
    cat $ASHS_ATLAS/snap/snaplabels.txt | \
	awk '$1 > 0 {split($0,arr,"\""); sub(/[ \t]+/,"_",arr[2]); print $1,arr[2]}' \
	    > ${OUTPUT_DIRECTORY_FOR_DL}/snaplabels.txt
    LABIDS=($(cat ${OUTPUT_DIRECTORY_FOR_DL}/snaplabels.txt | awk '{print $1}'))
    LABNAMES=($(cat ${OUTPUT_DIRECTORY_FOR_DL}/snaplabels.txt | awk '{print $2}'))
    
    for side in left right ; do
	TIMEPOINTS_COUNT=0
	WARP_COUNT=0
	for (( i=0; i < ${#ANATOMICAL_IMAGES[@]}; i+=$NUMBER_OF_MODALITIES )) 
	do   
	    BASENAME_ID=`basename ${ANATOMICAL_IMAGES[$i]}`
	    BASENAME_ID=${BASENAME_ID/\.nii\.gz/}
	    BASENAME_ID=${BASENAME_ID/\.nii/}
	    logCmd ${ANTSPATH}/antsApplyTransforms \
		   -d 3 \
		   -i ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/final/*${side}_lfseg_heur.nii.gz \
		   -o ${OUTPUT_DIRECTORY_FOR_DL}/${side}SSTLabelsWarpedTo${TIMEPOINTS_COUNT}.nii.gz \
		   -r ${ANATOMICAL_IMAGES[${TIMEPOINTS_COUNT}]} \
		   -t [${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/T_${BASENAME_ID}${WARP_COUNT}Affine.txt,1] \
		   -t ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/T_${BASENAME_ID}${WARP_COUNT}InverseWarp.nii.gz \
		   -n GenericLabel[Linear]
	    #measure the volumes
	    SBC=${OUTPUT_DIRECTORY_FOR_DL}/${side}SSTLabelsWarpedTo${TIMEPOINTS_COUNT}.nii.gz 
	    #Collect the Seg Stats in a pretty way
	    if [[ -f $SBC ]]; then
		# Generate the voxel and extent statistics
		STATS=${OUTPUT_DIRECTORY_FOR_DL}/${BASENAME_ID}${side}SSTLabelsWarpedToTimePoint${TIMEPOINTS_COUNT}_stats_raw.txt
		$ASHS_ROOT/ext/Linux/bin/c3d $SBC -dup -lstat | tee $STATS
		# Create an output file
		FNBODYVOL=${OUTPUT_DIRECTORY_FOR_DL}/${BASENAME_ID}${side}SSTLabelsWarpedToTimePoint${TIMEPOINTS_COUNT}_stats.txt
		rm -rf $FNBODYVOL
		# Dump volumes into that file
		for ((ilab = 0; ilab < ${#LABIDS[*]}; ilab++)); do
		    # The id of the label
		    j=${LABIDS[ilab]};
		    SUB=${LABNAMES[ilab]};
		    # Get the extent along z axis
		    NBODY=$(cat $STATS | awk -v id=$j '$1 == id {print $10}')
		    # Get the volume of this subfield
		    VSUB=$(cat $STATS | awk -v id=$j '$1 == id {print $7}')
		    # Write the volume information to output file
		    if [[ $NBODY ]]; then
			echo ${BASENAME_ID} $side $SUB $NBODY $VSUB >> $FNBODYVOL
		    fi
		done
	    fi
	    rm $STATS
	    let WARP_COUNT=${WARP_COUNT}+2
	    let TIMEPOINTS_COUNT=${TIMEPOINTS_COUNT}+1
	done
	   
    done
    
    time_end_DL=`date +%s`
    time_elapsed_DL=$((time_end_DL - time_start_DL))

    echo
    echo "###########################################################################################"
    echo " Done with Diet LASHiS:  $(( time_elapsed_DL / 3600 ))h $(( time_elapsed_DL %3600 / 60 ))m $(( time_elapsed_DL % 60 ))s"
    echo "###########################################################################################"
    echo
    exit 0
fi
################################################################################
#
#  Run each individual subject through ASHS
#
################################################################################

echo
echo "###########################################################################################"
echo " Run each individual through ASHS                                                     "
echo "###########################################################################################"
echo

time_start_ashs=`date +%s`


SUBJECT_COUNT=0
for (( i=0; i < ${#ANATOMICAL_IMAGES[@]}; i+=$NUMBER_OF_MODALITIES )) 
do
    
    BASENAME_ID=`basename ${ANATOMICAL_IMAGES[$i]}`
    BASENAME_ID=${BASENAME_ID/\.nii\.gz/}
    BASENAME_ID=${BASENAME_ID/\.nii/}

    OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS=${OUTPUT_DIR}/${BASENAME_ID}
    OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS=${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}_${SUBJECT_COUNT}

    echo $OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS

    if [[ ! -d $OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS ]];
    then
        echo "The output directory \"$OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS\" does not exist. Making it."
        mkdir -p $OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS
    fi

    let SUBJECT_COUNT=${SUBJECT_COUNT}+1

    ANATOMICAL_REFERENCE_IMAGE=${ANATOMICAL_IMAGES[$i]}
    
    SUBJECT_ANATOMICAL_IMAGES=''
    
    let k=$i+$NUMBER_OF_MODALITIES
    for (( j=$i; j < $k; j++ ))
    do
	#mkdir ${OUTPUT_LOCAL_PREFIX}/tmpfiles
        SUBJECT_ANATOMICAL_IMAGES="${SUBJECT_ANATOMICAL_IMAGES} -a ${ANATOMICAL_IMAGES[$j]}"
	SUBJECT_TSE=${ANATOMICAL_IMAGES[$j]}
	#cp ${ANATOMICAL_REFERENCE_IMAGE[$i]} ${OUTPUT_LOCAL_PREFIX}/tmpfiles/mprage.nii.gz
	#cp ${ANATOMICAL_REFERENCE_IMAGE[$i]} ${OUTPUT_LOCAL_PREFIX}/tmpfiles/tse.nii.gz
    done
    
    
    OUTPUT_LOCAL_PREFIX=${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}/${BASENAME_ID}

    if [[ ! -f ${OUTPUT_LOCAL_PREFIX}/final/${BASENAME_ID}_right_lfseg_heur.nii.gz ]] ;
    then
	logCmd ${ASHS_ROOT}/bin/ashs_main.sh \
	    -a ${ASHS_ATLAS} \
	    -g ${ANATOMICAL_REFERENCE_IMAGE} \
	    -f ${SUBJECT_TSE} \
	    -w ${OUTPUT_LOCAL_PREFIX} \
	    -T \
	    ${ASHS_QSUBOPTS} \
	    ${ASHS_CONFIG} \
	    ${ASHS_SGE_OPTS} 
	

	#cleanup
	#-g ${OUTPUT_LOCAL_PREFIX}/tmpfiles/mprage.nii.gz \
	#-f ${OUTPUT_LOCAL_PREFIX}/tmpfiles/tse.nii.gz \
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/affine_t1_to_template
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/ants_t1_to_temp
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/bootstrap
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/dump
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/flirt_t2_to_t1
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/mprage_raw.nii.gz
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/tse_raw.nii.gz
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/mprage_to_chunk*
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/final/*regmask
	logCmd rm -rf ${OUTPUT_LOCAL_PREFIX}/tmpfiles
    fi
done


time_end_ashs=`date +%s`
time_elapsed_ashs=$((time_end_ashs - time_start_ashs))

echo
echo "###########################################################################################"
echo " Done with individual ASHS:  $(( time_elapsed_ashs / 3600 ))h $(( time_elapsed_ashs %3600 / 60 ))m $(( time_elapsed_ashs % 60 ))s"
echo "###########################################################################################"
echo

################################
## START JLF AND REVERSE NORM  #
################################

echo
echo "###########################################################################################"
echo " JLF the ASHS results to the SST                                                      "
echo "###########################################################################################"
echo

time_start_jlf=`date +%s`

OUTPUT_DIRECTORY_FOR_LASHiS=${OUTPUT_DIR}/LASHiS
OUTPUT_DIRECTORY_FOR_LASHiS_POSTERIORS=${OUTPUT_DIRECTORY_FOR_LASHiS}/posteriors
OUTPUT_DIRECTORY_FOR_LASHiS_JLF_OUTPUTS=${OUTPUT_DIRECTORY_FOR_LASHiS}/JLF_label_output
XS_ASHS_DIR=${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}

logCmd mkdir -p ${OUTPUT_DIRECTORY_FOR_LASHiS}
logCmd mkdir -p ${OUTPUT_DIRECTORY_FOR_LASHiS_POSTERIORS}
logCmd mkdir -p ${OUTPUT_DIRECTORY_FOR_LASHiS_JLF_OUTPUTS}


#first get the labels ready
cat $ASHS_ATLAS/snap/snaplabels.txt | \
    awk '$1 > 0 {split($0,arr,"\""); sub(/[ \t]+/,"_",arr[2]); print $1,arr[2]}' \
	> ${OUTPUT_DIRECTORY_FOR_LASHiS}/snaplabels.txt

LABIDS=($(cat ${OUTPUT_DIRECTORY_FOR_LASHiS}/snaplabels.txt | awk '{print $1}'))
LABNAMES=($(cat ${OUTPUT_DIRECTORY_FOR_LASHiS}/snaplabels.txt | awk '{print $2}'))

#Then do the JLF and reverse normalisation

for side in left right ; do
    JLF_ATLAS_LABEL_OPTIONS=""
    SUBJECT_COUNT=0
    for (( i=0; i < ${#ANATOMICAL_IMAGES[@]}; i+=$NUMBER_OF_MODALITIES ))
    do
	
	BASENAME_ID=`basename ${ANATOMICAL_IMAGES[$i]}`
	BASENAME_ID=${BASENAME_ID/\.nii\.gz/}
	BASENAME_ID=${BASENAME_ID/\.nii/}
	OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS=${OUTPUT_DIR}/${BASENAME_ID}
	OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS=${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}_${SUBJECT_COUNT}
        let SUBJECT_COUNT=${SUBJECT_COUNT}+1
	
	
	JLF_ATLAS_LABEL_OPTIONS="${JLF_ATLAS_LABEL_OPTIONS} -g ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}/${BASENAME_ID}/tse_native_chunk_${side}.nii.gz -l ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}/${BASENAME_ID}/final/*_${side}_lfseg_heur.nii.gz "
	
    done
    
    if [[  ! -f ${OUTPUT_DIRECTORY_FOR_LASHiS_JLF_OUTPUTS}/${side}_SST_Labels.nii.gz ]] ;
    then

	JLF_ATLAS_LABEL_OPTIONS="${JLF_ATLAS_LABEL_OPTIONS} -g ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/tse_native_chunk_${side}.nii.gz -l ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/final/*${side}_lfseg_heur.nii.gz"
	echo "                                                                   "                                                    
	echo "Your JLF Atlas inputs and labels were:"
	echo "$JLF_ATLAS_LABEL_OPTIONS"
	echo "                                                                   "
	
    	logCmd $ANTSPATH/antsJointLabelFusion2.sh \
	       -d 3 \
	       -c ${DOQSUB} \
	       -j ${CORES} \
	       -t ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_TEMPLATE}/SST_ASHS/tse_native_chunk_${side}.nii.gz \
	       ${JLF_ATLAS_LABEL_OPTIONS} \
	       -o ${OUTPUT_DIRECTORY_FOR_LASHiS_JLF_OUTPUTS}/${side}_SST_ \
	       -p  ${OUTPUT_DIRECTORY_FOR_LASHiS_POSTERIORS}/${i}_${side}%04d.nii.gz \
	       -k 1 \
	       -z $MEMORY_PARAM_jlf \
	       -v $registration_memory_limit \
	       -u $JLF_walltime_param \
	       -w $registration_walltime_param 
    fi
    
    SUBJECT_COUNT=0
    TIMEPOINTS_COUNT=0
    for (( i=0; i < ${#ANATOMICAL_IMAGES[@]} ; i+=$NUMBER_OF_MODALITIES )) 
    do
	BASENAME_ID=`basename ${ANATOMICAL_IMAGES[$i]}`
	BASENAME_ID=${BASENAME_ID/\.nii\.gz/}
	BASENAME_ID=${BASENAME_ID/\.nii/}
	OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS=${OUTPUT_DIR}/${BASENAME_ID}
	OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS=${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}_${TIMEPOINTS_COUNT}
	
	#Reverse Norm
	
	logCmd ${ANTSPATH}/antsApplyTransforms \
	       -d 3 \
	       -i ${OUTPUT_DIRECTORY_FOR_LASHiS_JLF_OUTPUTS}/${side}_SST_Labels.nii.gz \
	       -o ${OUTPUT_DIRECTORY_FOR_LASHiS}/${side}SSTLabelsWarpedTo${TIMEPOINTS_COUNT}.nii.gz \
	       -r ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}/${BASENAME_ID}/tse.nii.gz \
	       -t [${OUTPUT_DIRECTORY_FOR_LASHiS_JLF_OUTPUTS}/${side}_SST_tse_native_chunk_${side}_${TIMEPOINTS_COUNT}_0GenericAffine.mat,1] \
	       -t ${OUTPUT_DIRECTORY_FOR_LASHiS_JLF_OUTPUTS}/${side}_SST_tse_native_chunk_${side}_${TIMEPOINTS_COUNT}_1InverseWarp.nii.gz \
	       -n GenericLabel[Linear]

	#copy the tse in for easy reference
	cp ${OUTPUT_DIRECTORY_FOR_SINGLE_SUBJECT_ASHS}/${BASENAME_ID}/tse.nii.gz ${OUTPUT_DIRECTORY_FOR_LASHiS}/tse_${TIMEPOINTS_COUNT}.nii.gz
	
	if [[ ! -f ${OUTPUT_DIRECTORY_FOR_LASHiS}/${side}SSTLabelsWarpedTo${TIMEPOINTS_COUNT}.nii.gz ]]; #JLF_FILES
	then
	    echo "Error:  The JLF files were not created.  Exiting."
	    exit 1
	fi

	SBC=${OUTPUT_DIRECTORY_FOR_LASHiS}/${side}SSTLabelsWarpedTo${TIMEPOINTS_COUNT}.nii.gz 

	#Collect the Seg Stats in a pretty way

	if [[ -f $SBC ]]; then

	    # Generate the voxel and extent statistics
	    STATS=${OUTPUT_DIRECTORY_FOR_LASHiS}/JLF_label_output/${BASENAME_ID}${side}SSTLabelsWarpedToTimePoint${TIMEPOINTS_COUNT}_stats_raw.txt
	    $ASHS_ROOT/ext/Linux/bin/c3d $SBC -dup -lstat | tee $STATS
	    # Create an output file
	    FNBODYVOL=${OUTPUT_DIRECTORY_FOR_LASHiS}/${BASENAME_ID}${side}SSTLabelsWarpedToTimePoint${TIMEPOINTS_COUNT}_stats.txt
	    rm -rf $FNBODYVOL

	    # Dump volumes into that file
	    for ((ilab = 0; ilab < ${#LABIDS[*]}; ilab++)); do

		# The id of the label
		j=${LABIDS[ilab]};
		SUB=${LABNAMES[ilab]};

		# Get the extent along z axis
		NBODY=$(cat $STATS | awk -v id=$j '$1 == id {print $10}')

		# Get the volume of this subfield
		VSUB=$(cat $STATS | awk -v id=$j '$1 == id {print $7}')

		# Write the volume information to output file
		if [[ $NBODY ]]; then
		    echo ${BASENAME_ID} $side $SUB $NBODY $VSUB >> $FNBODYVOL
		fi

	    done
	fi
	let SUBJECT_COUNT=${SUBJECT_COUNT}+2
	let TIMEPOINTS_COUNT=${TIMEPOINTS_COUNT}+1
    done
done



time_end_jlf=`date +%s`
time_elapsed_jlf=$((time_end_jlf - time_start_jlf))


time_end=`date +%s`
time_elapsed=$((time_end - time_start))

echo
echo "###########################################################################################"
echo " Done with LASHiS pipeline! "
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s"
echo "###########################################################################################"

exit 0
