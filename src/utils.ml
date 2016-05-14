open Bistro.EDSL_bash

(* process substitution for gunzip *)
let psgunzip x =
  seq ~sep:"" [ string "<(gunzip -c " ; dep x ; string ";)" ] ;
