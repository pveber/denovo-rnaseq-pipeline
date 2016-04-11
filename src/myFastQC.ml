open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

let run fq_gz = Bistro.Workflow.make ~descr:"fastQC" [%bash{|
DEST={{ dest }}
mkdir $DEST

set -e
zcat {{ dep fq_gz }} | fastqc --outdir=$DEST
rm -rf $DEST/*.zip
mv $DEST/*_fastqc/* $DEST
rm -rf $DEST/*_fastqc
|}]

