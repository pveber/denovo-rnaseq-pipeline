open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std
open Bistro.EDSL_sh

let trinity fa1 fa2 =
  workflow ~descr:"trinity" ~np:10 ~mem:(140 * 1024) [
    cmd "Trinity" [
      string "--verbose" ;
      string "--seqType fa" ;
      opt "--left" dep fa1 ;
      opt "--right" dep fa2 ;
      opt "--CPU" ident np ;
      opt "--max_memory" ident (seq [ string "$((" ; mem ; string " / 1024))" ]) ;
      opt "--output" ident dest ;
    ]
  ]
