open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

let transdecoder fa =
  workflow ~descr:"transdecoder.longOrfs" [
    mkdir_p tmp ;
    cmd "ln" [ string "-s " ; dep fa ; tmp // "transcripts.fa" ] ;
    and_list [
      cmd "cd" [ tmp ] ;
      cmd "TransDecoder.LongOrfs" [ opt "-t" string "transcripts.fa" ] ;
      cmd "TransDecoder.Predict"  [ opt "-t" string "transcripts.fa" ] ;
    ] ;
    mkdir_p dest ;
    mv (tmp // "transcripts.fa.transdecoder.*") dest ;
  ]

let cds = selector ["transcripts.fa.transdecoder.cds"]
