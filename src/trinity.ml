open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

let trinity ?(mem = 128) fa1 fa2 =
  let tmp_dest = tmp // "trinity" in
  workflow ~descr:"trinity" ~np:10 ~mem:(mem * 1024) [
    mkdir_p tmp ;
    cmd "Trinity" [
      string "--verbose" ;
      string "--seqType fa" ;
      opt "--left" dep fa1 ;
      opt "--right" dep fa2 ;
      opt "--CPU" ident np ;
      opt "--max_memory" ident (seq [ string "$((" ; Bistro.EDSL_sh.mem ; string " / 1024))G" ]) ;
      opt "--output" ident tmp_dest ;
    ] ;
    cmd "mv" [
      tmp_dest // "Trinity.fasta" ;
      dest ;
    ]
  ]
