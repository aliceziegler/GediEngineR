#!/bin/bash

#SBATCH --time=400:00:00
#SBATCH --ntasks=1 ###RS 10.10.
#SBATCH --cpus-per-task=20
#SBATCH --output=../../slurm/examplejob_%A.out
#SBATCH --mem-per-cpu=3900M ###RS 10.10.
#SBATCH --mail-user=alice.ziegler@geo.uni-marburg.de
#SBATCH --mail-type=END


module purge ###to empty storage before start (recommended at user meeting)
module load gnu9/9.4.0
module load R

###export OMP_NUM_THREADS=1

### module spider R
Rscript --vanilla 060_R_run_model.R
