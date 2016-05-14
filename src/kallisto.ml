open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

let index fas =
  workflow ~descr:"kallisto-index" [
    cmd "kallisto index" [
      opt "-i" ident dest ;
      list ~sep:" " dep fas ;
    ]
  ]

let quant ?bootstrap_samples idx fq1 fq2 =
  let open Bistro.EDSL_bash in
  workflow ~descr:"kallisto-quant" ~np:4 [
    cmd "kallisto quant" [
      opt "-i" dep idx ;
      opt "-o" ident dest ;
      opt "-t" ident np ;
      option (opt "-b" int) bootstrap_samples ;
      Utils.psgunzip fq1 ;
      Utils.psgunzip fq2 ;
    ]
  ]
