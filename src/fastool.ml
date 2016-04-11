open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

let fastool fqgz =
  workflow ~descr:"fastool" [
    pipe [
      cmd "zcat" [ dep fqgz ] ;
      cmd "fastool" ~stdout:dest [
        string "--illumina-trinity"
      ] ;
    ]
  ]
