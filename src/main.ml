open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std

let ( / ) = Bistro.EDSL.( / )



let np = 4
let mem = 10 * 1024

let pipeline fq1_path fq2_path =
  let fq1_gz = Bistro.Workflow.input fq1_path in
  let fq2_gz = Bistro.Workflow.input fq2_path in
  let initial_fastqc1 = MyFastQC.run fq1_gz in
  let initial_fastqc2 = MyFastQC.run fq2_gz in
  let trimmed_fq1_gz, trimmed_fq2_gz =
    Ea_utils.fastq_mcf ~quality_threshold:30 ~quality_mean:25 fq1_gz fq2_gz
  in
  let post_trimming_fastqc1 = MyFastQC.run trimmed_fq1_gz in
  let post_trimming_fastqc2 = MyFastQC.run trimmed_fq2_gz in
  let fa1 = Fastool.fastool trimmed_fq1_gz in
  let fa2 = Fastool.fastool trimmed_fq2_gz in
  let trinity_assembly = Trinity.trinity fa1 fa2 in
  Bistro_app.[
    [ "o" ; "FastQC" ; "initial" ; "1" ] %> initial_fastqc1 ;
    [ "o" ; "FastQC" ; "initial" ; "2" ] %> initial_fastqc2 ;
    [ "o" ; "FastQC" ; "post_trimming" ; "1" ] %> post_trimming_fastqc1 ;
    [ "o" ; "FastQC" ; "post_trimming" ; "2" ] %> post_trimming_fastqc2 ;
    [ "o" ; "Trinity" ] %> trinity_assembly ;
  ]

let main workdir fq1_path fq2_path () =
  let backend = Bistro_engine.Scheduler.local_backend ?workdir ~np ~mem () in
  let targets = List.concat [
      pipeline fq1_path fq2_path
    ]
  in
  Bistro_app.with_backend backend targets

let spec =
  let open Command.Spec in
  empty
  +> flag "--workdir"  (optional string) ~doc:"DIR (Preferably local) directory for temporary files"
  +> anon ("FQ1" %: file)
  +> anon ("FQ2" %: file)

let command =
  Command.basic
    ~summary:"De novo RNA-seq pipeline"
    spec
    main

let () = Command.run ~version:"0.1" command
