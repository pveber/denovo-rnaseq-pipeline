open Core.Std
open Bistro.Std
open Bistro_bioinfo.Std

let ( / ) = Bistro.EDSL.( / )


let gunzip_fastq_prefix n fq_gz =
  let open Bistro.EDSL_sh in
  workflow ~descr:"gunzip_fastq_prefix" [
    pipe [
      cmd "zcat" [ dep fq_gz ] ;
      cmd "head" [ opt "-n" int (n * 4) ] ;
      cmd "gzip" ~stdout:dest [ string "--stdout" ] ;
    ]
  ]

let pipeline preview_mode fq1_path fq2_path =
  let fq1_gz = Bistro.Workflow.input fq1_path in
  let fq2_gz = Bistro.Workflow.input fq2_path in
  let fq1_gz, fq2_gz =
    if preview_mode
    then
      let f = gunzip_fastq_prefix 1000000 in
      f fq1_gz, f fq2_gz
    else fq1_gz, fq2_gz
  in
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
    [ "fasta1" ] %> fa1 ;
    [ "FastQC" ; "initial" ; "1" ] %> initial_fastqc1 ;
    [ "FastQC" ; "initial" ; "2" ] %> initial_fastqc2 ;
    [ "FastQC" ; "post_trimming" ; "1" ] %> post_trimming_fastqc1 ;
    [ "FastQC" ; "post_trimming" ; "2" ] %> post_trimming_fastqc2 ;
    [ "Trinity" ] %> trinity_assembly ;
  ]

let main preview_mode outdir tmpdir np mem fq1_path fq2_path () =
  let backend = Bistro_engine.Scheduler.local_backend ?tmpdir ~np ~mem:(mem * 1024) () in
  let targets = pipeline preview_mode fq1_path fq2_path in
  Bistro_app.with_backend ~outdir backend targets

let spec =
  let open Command.Spec in
  empty
  +> flag "--preview-mode" no_arg ~doc:" Run on a small subset of the data"
  +> flag "--outdir"  (required string) ~doc:"DIR Directory where to link exported targets"
  +> flag "--tmpdir"  (optional string) ~doc:"DIR (Preferably local) directory for temporary files"
  +> flag "--np"      (optional_with_default 4 int) ~doc:"INT Number of processors"
  +> flag "--mem"     (optional_with_default 4 int) ~doc:"INT Available memory (in GB)"
  +> anon ("FQ1" %: file)
  +> anon ("FQ2" %: file)

let command =
  Command.basic
    ~summary:"De novo RNA-seq pipeline"
    spec
    main

let () = Command.run ~version:"0.1" command
