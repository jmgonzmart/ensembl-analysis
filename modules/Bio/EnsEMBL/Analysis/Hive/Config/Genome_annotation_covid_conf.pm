=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2020] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package Bio::EnsEMBL::Analysis::Hive::Config::Genome_annotation_covid_conf;

use strict;
use warnings;
use File::Spec::Functions;

use Bio::EnsEMBL::ApiVersion qw/software_version/;
use Bio::EnsEMBL::Analysis::Tools::Utilities qw(get_analysis_settings);
use Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf;
use base ('Bio::EnsEMBL::Analysis::Hive::Config::HiveBaseConfig_conf');

sub default_options {
  my ($self) = @_;
  return {
    # inherit other stuff from the base class
    %{ $self->SUPER::default_options() },

######################################################
#
# Variable settings- You change these!!!
#
######################################################
########################
# Misc setup info
########################
    'protein_file'              => '',
    'dbowner'                   => '' || $ENV{EHIVE_USER} || $ENV{USER},
    'pipeline_name'             => '' || $self->o('production_name').$self->o('production_name_modifier').'_'.$self->o('ensembl_release'),
    'user_r'                    => '', # read only db user
    'user'                      => '', # write db user
    'password'                  => '', # password for write db user
    'server_set'                => '', # What server set to user, e.g. set1
    'pipe_db_server'            => '', # host for pipe db
    'databases_server'          => '', # host for general output dbs
    'dna_db_server'             => '', # host for dna db
    'pipe_db_port'              => '', # port for pipeline host
    'databases_port'            => '', # port for general output db host
    'dna_db_port'               => '', # port for dna db host
    'registry_host'             => '', # host for registry db
    'registry_port'             => '', # port for registry db
    'registry_db'               => '', # name for registry db
    'repbase_logic_name'        => '', # repbase logic name i.e. repeatmask_repbase_XXXX, ONLY FILL THE XXXX BIT HERE!!! e.g primates
    'repbase_library'           => '', # repbase library name, this is the actual repeat repbase library to use, e.g. "Mus musculus"
    'rnaseq_summary_file'       => '' || catfile($self->o('rnaseq_dir'), $self->o('species_name').'.csv'), # Set this if you have a pre-existing cvs file with the expected columns
    'rnaseq_summary_file_genus' => '' || catfile($self->o('rnaseq_dir'), $self->o('species_name').'_gen.csv'), # Set this if you have a pre-existing genus level cvs file with the expected columns
    'long_read_summary_file'    => '' || catfile($self->o('long_read_dir'), $self->o('species_name').'_long_read.csv'), # csv file for minimap2, should have 2 columns tab separated cols: sample_name\tfile_name
    'long_read_summary_file_genus' => '' || catfile($self->o('long_read_dir'), $self->o('species_name').'_long_read_gen.csv'), # csv file for minimap2, should have 2 columns tab separated cols: sample_name\tfile_name
    'long_read_fastq_dir'       => '' || catdir($self->o('long_read_dir'),'input'),
    'release_number'            => '' || $self->o('ensembl_release'),
    'species_name'              => '', # e.g. mus_musculus
    'production_name'           => '' || $self->o('species_name'), # usually the same as species name but currently needs to be a unique entry for the production db, used in all core-like db names
    'taxon_id'                  => '', # should be in the assembly report file
    'species_taxon_id'          => '' || $self->o('taxon_id'), # Species level id, could be different to taxon_id if we have a subspecies, used to get species level RNA-seq CSV data
    'genus_taxon_id'            => '' || $self->o('taxon_id'), # Genus level taxon id, used to get a genus level csv file in case there is not enough species level transcriptomic data
    'uniprot_set'               => '', # e.g. mammals_basic, check UniProtCladeDownloadStatic.pm module in hive config dir for suitable set,
    'output_path'               => '', # Lustre output dir. This will be the primary dir to house the assembly info and various things from analyses
    'wgs_id'                    => '', # Can be found in assembly report file on ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/
    'assembly_name'             => '', # Name (as it appears in the assembly report file)
    'assembly_accession'        => '', # Versioned GCA assembly accession, e.g. GCA_001857705.1
    'assembly_refseq_accession' => '', # Versioned GCF accession, e.g. GCF_001857705.1
    'stable_id_prefix'          => '', # e.g. ENSPTR. When running a new annotation look up prefix in the assembly registry db
    'use_genome_flatfile'       => '1',# This will read sequence where possible from a dumped flatfile instead of the core db
    'species_url'               => '' || $self->o('production_name').$self->o('production_name_modifier'), # sets species.url meta key
    'species_division'          => 'EnsemblVertebrates', # sets species.division meta key
    'stable_id_start'           => '0', # When mapping is not required this is usually set to 0
    'skip_repeatmodeler'        => '0', # Skip using our repeatmodeler library for the species with repeatmasker, will still run standard repeatmasker
    'skip_post_repeat_analyses' => '0', # Will everything after the repreats (rm, dust, trf) in the genome prep phase if 1, i.e. skips cpg, eponine, genscan, genscan blasts etc.
    'skip_projection'           => '0', # Will skip projection process if 1
    'skip_lastz'                => '0', # Will skip lastz if 1 (if skip_projection is enabled this is irrelevant)
    'skip_rnaseq'               => '0', # Will skip rnaseq analyses if 1
    'skip_long_read'            => '1', # Will skip long read analyses if 1
    'skip_ncrna'                => '0', # Will skip ncrna process if 1
    'skip_cleaning'             => '0', # Will skip the cleaning phase, will keep more genes/transcripts but some lower quality models may be kept
    'mapping_required'          => '0', # If set to 1 this will run stable_id mapping sometime in the future. At the moment it does nothing
    'mapping_db'                => '', # Tied to mapping_required being set to 1, we should have a mapping db defined in this case, leave undef for now
    'uniprot_version'           => 'uniprot_2018_07', # What UniProt data dir to use for various analyses
    'vertrna_version'           => '136', # The version of VertRNA to use, should correspond to a numbered dir in VertRNA dir
    'paired_end_only'           => '1', # Will only use paired-end rnaseq data if 1
    'ig_tr_fasta_file'          => 'human_ig_tr.fa', # What IMGT fasta file to use. File should contain protein segments with appropriate headers
    'mt_accession'              => undef, # This should be set to undef unless you know what you are doing. If you specify an accession, then you need to add the parameters to the load_mitochondrion analysis
    'production_name_modifier'  => '', # Do not set unless working with non-reference strains, breeds etc. Must include _ in modifier, e.g. _hni for medaka strain HNI
    'compara_registry_file'     => '',

    # Keys for custom loading, only set/modify if that's what you're doing
    'skip_genscan_blasts'          => '1',
    'load_toplevel_only'           => '1', # This will not load the assembly info and will instead take any chromosomes, unplaced and unlocalised scaffolds directly in the DNA table
    'custom_toplevel_file_path'    => '', # Only set this if you are loading a custom toplevel, requires load_toplevel_only to also be set to 2
    'repeatmodeler_library'        => '', # This should be the path to a custom repeat library, leave blank if none exists
    'use_repeatmodeler_to_mask'    => '0', # Setting this will include the repeatmodeler library in the masking process

    'clade' => $self->o('repbase_logic_name'),

    'base_blast_db_path'        => $ENV{BLASTDB_DIR},
    'uniprot_version'           => 'uniprot_2018_07',
    'protein_entry_loc'            => catfile($self->o('base_blast_db_path'), 'uniprot', $self->o('uniprot_version'), 'entry_loc'),

########################
# Pipe and ref db info
########################
    'provider_name'                => 'Ensembl',
    'provider_url'                 => 'rapid.ensembl.org',

    'pipe_db_name'                  => $self->o('dbowner').'_'.$self->o('production_name').$self->o('production_name_modifier').'_pipe_'.$self->o('release_number'),
    'dna_db_name'                   => $self->o('dbowner').'_'.$self->o('production_name').$self->o('production_name_modifier').'_core_'.$self->o('release_number'),

    'core_db_name'     => $self->o('dna_db_name'),
    'core_db_server'  => $self->o('dna_db_server'),
    'core_db_port'    => $self->o('dna_db_port'),

    # This is used for the ensembl_production and the ncbi_taxonomy databases
    'ensembl_release'              => $ENV{ENSEMBL_RELEASE}, # this is the current release version on staging to be able to get the correct database
    'production_db_server'         => 'mysql-ens-meta-prod-1',
    'production_db_port'           => '4483',


######################################################
#
# Mostly constant settings
#
######################################################

    genome_dumps                  => catdir($self->o('output_path'), 'genome_dumps'),
    # This one is used by most analyses that run against a genome flatfile like exonerate, genblast etc. Has slice name style headers. Is softmasked
    softmasked_genome_file        => catfile($self->o('genome_dumps'), $self->o('species_name').'_softmasked_toplevel.fa'),
    # This one is used in replacement of the dna table in the core db, so where analyses override slice->seq. Has simple headers with just the seq_region name. Also used by bwa in the RNA-seq analyses. Not masked
    faidx_genome_file             => catfile($self->o('genome_dumps'), $self->o('species_name').'_toplevel.fa'),
    # This one is a cross between the two above, it has the seq_region name header but is softmasked. It is used by things that would both want to skip using the dna table and also want to avoid the repeat_feature table, e.g. bam2introns
    faidx_softmasked_genome_file  => catfile($self->o('genome_dumps'), $self->o('species_name').'_softmasked_toplevel.fa.reheader'),
    'primary_assembly_dir_name' => 'Primary_Assembly',
    'refseq_cdna_calculate_coverage_and_pid' => '0',
    'contigs_source'            => 'ena',


    ensembl_analysis_script           => catdir($self->o('enscode_root_dir'), 'ensembl-analysis', 'scripts'),
    remove_duplicates_script_path     => catfile($self->o('ensembl_analysis_script'), 'find_and_remove_duplicates.pl'),
    flag_potential_pseudogenes_script => catfile($self->o('ensembl_analysis_script'), 'genebuild', 'flag_potential_pseudogenes.pl'),
    load_optimise_script              => catfile($self->o('ensembl_analysis_script'), 'genebuild', 'load_external_db_ids_and_optimize_af.pl'),
    prepare_cdnas_script              => catfile($self->o('ensembl_analysis_script'), 'genebuild', 'prepare_cdnas.pl'),
    load_fasta_script_path            => catfile($self->o('ensembl_analysis_script'), 'genebuild', 'load_fasta_to_db_table.pl'),
    loading_report_script             => catfile($self->o('ensembl_analysis_script'), 'genebuild', 'report_genome_prep_stats.pl'),
    refseq_synonyms_script_path       => catfile($self->o('ensembl_analysis_script'), 'refseq', 'load_refseq_synonyms.pl'),
    refseq_import_script_path         => catfile($self->o('ensembl_analysis_script'), 'refseq', 'parse_ncbi_gff3.pl'),
    sequence_dump_script              => catfile($self->o('ensembl_analysis_script'), 'sequence_dump.pl'),
    sncrna_analysis_script             => catdir($self->o('ensembl_analysis_script'), 'genebuild', 'sncrna'),

    ensembl_misc_script        => catdir($self->o('enscode_root_dir'), 'ensembl', 'misc-scripts'),
    repeat_types_script        => catfile($self->o('ensembl_misc_script'), 'repeats', 'repeat-types.pl'),
    meta_coord_script          => catfile($self->o('ensembl_misc_script'), 'meta_coord', 'update_meta_coord.pl'),
    meta_levels_script         => catfile($self->o('ensembl_misc_script'), 'meta_levels.pl'),
    frameshift_attrib_script   => catfile($self->o('ensembl_misc_script'), 'frameshift_transcript_attribs.pl'),
    select_canonical_script    => catfile($self->o('ensembl_misc_script'),'canonical_transcripts', 'select_canonical_transcripts.pl'),
    assembly_name_script       => catfile($self->o('ensembl_analysis_script'), 'update_assembly_name.pl'),

    rnaseq_daf_introns_file => catfile($self->o('output_dir'), 'rnaseq_daf_introns.dat'),

    # Genes biotypes to ignore from the final db when copying to core
    copy_biotypes_to_ignore => {
                                 'low_coverage' => 1,
                                 'CRISPR' => 1,
                               },
########################
# Extra db settings
########################

    'num_tokens' => 10,
    mysql_dump_options => '--max_allowed_packet=1000MB',

########################
# Executable paths
########################
    'minimap2_genome_index'  => $self->o('faidx_genome_file').'.mmi',
    'minimap2_path'          => '/hps/nobackup2/production/ensembl/fergal/coding/long_read_aligners/new_mm2/minimap2/minimap2',
    'paftools_path'          => '/hps/nobackup2/production/ensembl/fergal/coding/long_read_aligners/new_mm2/minimap2/misc/paftools.js',
    'minimap2_batch_size'    => '5000',

    'blast_type' => 'ncbi', # It can be 'ncbi', 'wu', or 'legacy_ncbi'
    'dust_path' => catfile($self->o('binary_base'), 'dustmasker'),
    'trf_path' => catfile($self->o('binary_base'), 'trf'),
    'eponine_java_path' => catfile($self->o('binary_base'), 'java'),
    'eponine_jar_path' => catfile($self->o('software_base_path'), 'opt', 'eponine', 'libexec', 'eponine-scan.jar'),
    'cpg_path' => catfile($self->o('binary_base'), 'cpg_lh'),
    'trnascan_path' => catfile($self->o('binary_base'), 'tRNAscan-SE'),
    'repeatmasker_path' => catfile($self->o('binary_base'), 'RepeatMasker'),
    'genscan_path' => catfile($self->o('binary_base'), 'genscan'),
    'genscan_matrix_path' => catfile($self->o('software_base_path'), 'share', 'HumanIso.smat'),
    'uniprot_blast_exe_path' => catfile($self->o('binary_base'), 'blastp'),
    'blastn_exe_path' => catfile($self->o('binary_base'), 'blastn'),
    'vertrna_blast_exe_path' => catfile($self->o('binary_base'), 'tblastn'),
    'unigene_blast_exe_path' => catfile($self->o('binary_base'), 'tblastn'),
    genewise_path => catfile($self->o('binary_base'), 'genewise'),
    'exonerate_path'         => catfile($self->o('software_base_path'), 'opt', 'exonerate09', 'bin', 'exonerate'),
    'cmsearch_exe_path'    => catfile($self->o('software_base_path'), 'bin', 'cmsearch'), # #'opt', 'infernal10', 'bin', 'cmsearch'),
    indicate_path  => catfile($self->o('binary_base'), 'indicate'),
    pmatch_path  => catfile($self->o('binary_base'), 'pmatch'),
    exonerate_annotation => catfile($self->o('binary_base'), 'exonerate'),
    samtools_path => catfile($self->o('binary_base'), 'samtools'), #You may need to specify the full path to the samtools binary
    picard_lib_jar => catfile($self->o('software_base_path'), 'Cellar', 'picard-tools', '2.6.0', 'libexec', 'picard.jar'), #You need to specify the full path to the picard library
    bwa_path => catfile($self->o('software_base_path'), 'opt', 'bwa-051mt', 'bin', 'bwa'), #You may need to specify the full path to the bwa binary
    refine_ccode_exe => catfile($self->o('binary_base'), 'RefineSolexaGenes'), #You may need to specify the full path to the RefineSolexaGenes binary
    interproscan_exe => catfile($self->o('binary_base'), 'interproscan.sh'),
    bedtools => catfile($self->o('binary_base'), 'bedtools'),
    bedGraphToBigWig => catfile($self->o('binary_base'), 'bedGraphToBigWig'),
    'cesar_path' => catdir($self->o('software_base_path'),'opt','cesar','bin'),

    'uniprot_genblast_batch_size' => 15,
    'uniprot_table_name'          => 'uniprot_sequences',

    'genblast_path'     => catfile($self->o('binary_base'), 'genblast'),
    'genblast_eval'     => $self->o('blast_type') eq 'wu' ? '1e-20' : '1e-1',
    'genblast_cov'      => '0.5',
    'genblast_pid'      => '30',
    'genblast_max_rank' => '5',
    'genblast_flag_small_introns' => 1,
    'genblast_flag_subpar_models' => 0,

    'ig_tr_table_name'    => 'ig_tr_sequences',
    'ig_tr_genblast_cov'  => '0.8',
    'ig_tr_genblast_pid'  => '70',
    'ig_tr_genblast_eval' => '1',
    'ig_tr_genblast_max_rank' => '5',
    'ig_tr_batch_size'    => 10,

    'exonerate_cdna_pid' => '95', # Cut-off for percent id
    'exonerate_cdna_cov' => '50', # Cut-off for coverage

    'cdna_selection_pid' => '97', # Cut-off for percent id for selecting the cDNAs
    'cdna_selection_cov' => '90', # Cut-off for coverage for selecting the cDNAs

# Best targetted stuff
    exonerate_logic_name => 'exonerate',
    ncbi_query => '((txid'.$self->o('taxon_id').'[Organism:noexp]+AND+biomol_mrna[PROP]))  NOT "tsa"[Properties]', 

    cdna_table_name    => 'cdna_sequences',
    target_exonerate_calculate_coverage_and_pid => 0,
    exonerate_protein_pid => 95,
    exonerate_protein_cov => 50,
    cdna2genome_region_padding => 2000,
    exonerate_max_intron => 200000,

    best_targetted_min_coverage => 50, # This is to avoid having models based on fragment alignment and low identity
    best_targetted_min_identity => 50, # This is to avoid having models based on fragment alignment and low identity


# RNA-seq pipeline stuff
    # You have the choice between:
    #  * using a csv file you already created
    #  * using a study_accession like PRJEB19386
    #  * using the taxon_id of your species
    # 'rnaseq_summary_file' should always be set. If 'taxon_id' or 'study_accession' are not undef
    # they will be used to retrieve the information from ENA and to create the csv file. In this case,
    # 'file_columns' and 'summary_file_delimiter' should not be changed unless you know what you are doing
    'study_accession'     => '',
    'max_reads_per_split' => 2500000, # This sets the number of reads to split the fastq files on
    'max_total_reads'     => 200000000, # This is the total number of reads to allow from a single, unsplit file

    'summary_file_delimiter' => '\t', # Use this option to change the delimiter for your summary data file
    'summary_csv_table' => 'csv_data',
    'read_length_table' => 'read_length',
    'rnaseq_data_provider' => 'ENA', #It will be set during the pipeline or it will use this value

    'rnaseq_dir'    => catdir($self->o('output_path'), 'rnaseq'),
    'input_dir'     => catdir($self->o('rnaseq_dir'),'input'),
    'output_dir'    => catdir($self->o('rnaseq_dir'),'output'),
    'merge_dir'     => catdir($self->o('rnaseq_dir'),'merge'),
    'sam_dir'       => catdir($self->o('rnaseq_dir'),'sams'),
    'header_file'   => catfile($self->o('output_dir'), '#'.$self->o('read_id_tag').'#_header.h'),

    'rnaseq_ftp_base' => 'ftp://ftp.sra.ebi.ac.uk/vol1/fastq/',

    'long_read_dir'       => catdir($self->o('output_path'),'long_read'),
    'long_read_fastq_dir' => catdir($self->o('long_read_dir'),'input'),
    'use_ucsc_naming' => 0,

    # If your reads are unpaired you may want to run on slices to avoid
    # making overlong rough models.  If you want to do this, specify a
    # slice length here otherwise it will default to whole chromosomes.
    slice_length => 10000000,

    # Regular expression to allow FastQ files to be correctly paired,
    # for example: file_1.fastq and file_2.fastq could be paired using
    # the expression "\S+_(\d)\.\S+".  Need to identify the read number
    # in brackets; the name the read number (1, 2) and the
    # extension.
    pairing_regex => '\S+_(\d)\.\S+',
    
    # Regular expressions for splitting the fastq files
    split_paired_regex   => '(\S+)(\_\d\.\S+)',
    split_single_regex  => '([^.]+)(\.\S+)',

    # Do you want to make models for the each individual sample as well
    # as for the pooled samples (1/0)?
    single_tissue => 1,

    # What Read group tag would you like to group your samples
    # by? Default = ID
    read_group_tag => 'SM',
    read_id_tag => 'ID',

    use_threads => 3,
    rnaseq_merge_threads => 12,
    rnaseq_merge_type => 'samtools',
    read_min_paired => 50,
    read_min_mapped => 50,
    other_isoforms => 'other', # If you don't want isoforms, set this to undef
    maxintron => 200000,

    # Please assign some or all columns from the summary file to the
    # some or all of the following categories.  Multiple values can be
    # separted with commas. ID, SM, DS, CN, is_paired, filename, read_length, is_13plus,
    # is_mate_1 are required. If pairing_regex can work for you, set is_mate_1 to -1.
    # You can use any other tag specified in the SAM specification:
    # http://samtools.github.io/hts-specs/SAMv1.pdf

    ####################################################################
    # This is just an example based on the file snippet shown below.  It
    # will vary depending on how your data looks.
    ####################################################################
    file_columns      => ['SM', 'ID', 'is_paired', 'filename', 'is_mate_1', 'read_length', 'is_13plus', 'CN', 'PL', 'DS'],
    long_read_columns => ['sample','filename'],

# lincRNA pipeline stuff
    'lncrna_dir' => catdir($self->o('output_path'), 'lincrna'),
    registry_file => catfile($self->o('lncrna_dir'), 'registry.pm'),
    'file_translations' => catfile($self->o('lncrna_dir'), 'hive_dump_translations.fasta'),
    'file_for_length' => catfile($self->o('lncrna_dir'), 'check_lincRNA_length.out'),  # list of genes that are smaller than 200bp, if any
    'file_for_biotypes' => catfile($self->o('lncrna_dir'), 'check_lincRNA_need_to_update_biotype_antisense.out'), # mysql queries that will apply or not in your dataset (check update_database) and will update biotypes
    'file_for_introns_support' => catfile($self->o('lncrna_dir'), 'check_lincRNA_Introns_supporting_evidence.out'), # for debug
    biotype_output => 'rnaseq',
    lincrna_protein_coding_set => [
      'rnaseq_merged_1',
      'rnaseq_merged_2',
      'rnaseq_merged_3',
      'rnaseq_merged_4',
      'rnaseq_merged_5',
      'rnaseq_tissue_1',
      'rnaseq_tissue_2',
      'rnaseq_tissue_3',
      'rnaseq_tissue_4',
      'rnaseq_tissue_5',
    ],

########################
# SPLIT PROTEOME File
########################
    'max_seqs_per_file' => 20,
    'max_seq_length_per_file' => 20000, # Maximum sequence length in a file
    'max_files_per_directory' => 1000, # Maximum number of files in a directory
    'max_dirs_per_directory'  => $self->o('max_files_per_directory'),

########################
# FINAL Checks parameters - Update biotypes to lincRNA, antisense, sense, problem ...
########################

     update_database => 'yes', # Do you want to apply the suggested biotypes? yes or no.

########################
# Interproscan
########################
    required_externalDb => '',
    interproscan_lookup_applications => [
      'PfamA',
    ],
    required_externalDb => [],
    pathway_sources => [],
    required_analysis => [
      {
        'logic_name'    => 'pfam',
        'db'            => 'Pfam',
        'db_version'    => '31.0',
        'ipscan_name'   => 'Pfam',
        'ipscan_xml'    => 'PFAM',
        'ipscan_lookup' => 1,
      },
    ],




# Max internal stops for projected transcripts
    'projection_pid'                        => '50',
    'projection_cov'                        => '50',
    'projection_max_internal_stops'         => '1',
    'projection_calculate_coverage_and_pid' => '1',

    'projection_lincrna_percent_id'         => 90,
    'projection_lincrna_coverage'           => 90,
    'projection_pseudogene_percent_id'      => 60,
    'projection_pseudogene_coverage'        => 75,
    'projection_ig_tr_percent_id'           => 70,
    'projection_ig_tr_coverage'             => 90,
    'projection_exonerate_padding'          => 5000,

    'realign_table_name'                    => 'projection_source_sequences',
    'max_projection_structural_issues'      => 1,

## Add in genewise path and put in matching code
    'genewise_pid'                        => '50',
    'genewise_cov'                        => '50',
    'genewise_region_padding'             => '50000',
    'genewise_calculate_coverage_and_pid' => '1',

########################
# Misc setup info
########################
    'repeatmasker_engine'       => 'crossmatch',
    'masking_timer_long'        => '5h',
    'masking_timer_short'       => '2h',

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# No option below this mark should be modified
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
########################################################
# URLs for retrieving the INSDC contigs and RefSeq files
########################################################
    'ncbi_base_ftp'           => 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all',
    'insdc_base_ftp'          => $self->o('ncbi_base_ftp').'/#expr(substr(#assembly_accession#, 0, 3))expr#/#expr(substr(#assembly_accession#, 4, 3))expr#/#expr(substr(#assembly_accession#, 7, 3))expr#/#expr(substr(#assembly_accession#, 10, 3))expr#/#assembly_accession#_#assembly_name#',
    'assembly_ftp_path'       => $self->o('insdc_base_ftp'),
    'refseq_base_ftp'         => $self->o('ncbi_base_ftp').'/#expr(substr(#assembly_refseq_accession#, 0, 3))expr#/#expr(substr(#assembly_refseq_accession#, 4, 3))expr#/#expr(substr(#assembly_refseq_accession#, 7, 3))expr#/#expr(substr(#assembly_refseq_accession#, 10, 3))expr#/#assembly_refseq_accession#_#assembly_name#',
    'refseq_import_ftp_path'  => $self->o('refseq_base_ftp').'/#assembly_refseq_accession#_#assembly_name#_genomic.gff.gz',
    'refseq_mrna_ftp_path'    => $self->o('refseq_base_ftp').'/#assembly_refseq_accession#_#assembly_name#_rna.fna.gz',
    'refseq_report_ftp_path' => $self->o('refseq_base_ftp').'/#assembly_refseq_accession#_#assembly_name#_assembly_report.txt',
##################################
# Memory settings for the analyses
##################################
    'default_mem'          => '900',
    'genblast_mem'         => '1900',
    'genblast_retry_mem'   => '4900',
    'genewise_mem'         => '3900',
    'genewise_retry_mem'   => '5900',
    'refseq_mem'           => '9900',
    'projection_mem'       => '1900',
    'layer_annotation_mem' => '3900',
    'genebuilder_mem'      => '1900',

########################
# db info
########################
    'core_db' => {
      -dbname => $self->o('dna_db_name'),
      -host   => $self->o('dna_db_server'),
      -port   => $self->o('dna_db_port'),
      -user   => $self->o('user'),
      -pass   => $self->o('password'),
      -driver => $self->o('hive_driver'),
    },



    'production_db' => {
      -host   => $self->o('production_db_server'),
      -port   => $self->o('production_db_port'),
      -user   => $self->o('user_r'),
      -pass   => $self->o('password_r'),
      -dbname => 'ensembl_production',
      -driver => $self->o('hive_driver'),
    },

    'taxonomy_db' => {
      -host   => $self->o('production_db_server'),
      -port   => $self->o('production_db_port'),
      -user   => $self->o('user_r'),
      -pass   => $self->o('password_r'),
      -dbname => 'ncbi_taxonomy',
      -driver => $self->o('hive_driver'),
    },

  };
}

sub pipeline_create_commands {
    my ($self) = @_;

    my $tables;
    my %small_columns = (
        paired => 1,
        read_length => 1,
        is_13plus => 1,
        is_mate_1 => 1,
        );
    # We need to store the values of the csv file to easily process it. It will be used at different stages
    foreach my $key (@{$self->default_options->{'file_columns'}}) {
        if (exists $small_columns{$key}) {
            $tables .= $key.' SMALLINT UNSIGNED NOT NULL,'
        }
        elsif ($key eq 'DS') {
            $tables .= $key.' VARCHAR(255) NOT NULL,'
        }
        else {
            $tables .= $key.' VARCHAR(50) NOT NULL,'
        }
    }
    $tables .= ' KEY(SM), KEY(ID)';

################
# LastZ
################

    my $second_pass     = exists $self->{'_is_second_pass'};
    $self->{'_is_second_pass'} = $second_pass;
    return $self->SUPER::pipeline_create_commands if $self->can('no_compara_schema');
    my $pipeline_url    = $self->pipeline_url();
    my $parsed_url      = $second_pass && Bio::EnsEMBL::Hive::Utils::URL::parse( $pipeline_url );
    my $driver          = $second_pass ? $parsed_url->{'driver'} : '';

################
# /LastZ
################

    return [
    # inheriting database and hive tables' creation
      @{$self->SUPER::pipeline_create_commands},
    ];
}


sub pipeline_wide_parameters {
  my ($self) = @_;

  return {
    %{$self->SUPER::pipeline_wide_parameters},
    load_toplevel_only => $self->o('load_toplevel_only'),
    wide_ensembl_release => $self->o('ensembl_release'),
    use_genome_flatfile  => $self->o('use_genome_flatfile'),
    genome_file          => $self->o('softmasked_genome_file'),
  }
}

=head2 create_header_line

 Arg [1]    : Arrayref String, it will contains the values of 'file_columns'
 Example    : create_header_line($self->o('file_columns');
 Description: It will create a RG line using only the keys present in your csv file
 Returntype : String representing the RG line in a BAM file
 Exceptions : None


=cut

sub create_header_line {
    my ($items) = shift;

    my @read_tags = qw(ID SM DS CN DT FO KS LB PG PI PL PM PU);
    my $read_line = '@RG';
    foreach my $rt (@read_tags) {
        $read_line .= "\t$rt:#$rt#" if (grep($rt eq $_, @$items));
    }
    return $read_line."\n";
}

## See diagram for pipeline structure
sub pipeline_analyses {
    my ($self) = @_;

    my %genblast_params = (
      wu    => '-P wublast -gff -e #blast_eval# -c #blast_cov#',
      ncbi  => '-P blast -gff -e #blast_eval# -c #blast_cov# -W 3 -softmask -scodon 50 -i 30 -x 10 -n 30 -d 200000 -g T',
      wu_genome    => '-P wublast -gff -e #blast_eval# -c #blast_cov#',
      ncbi_genome  => '-P blast -gff -e #blast_eval# -c #blast_cov# -W 3 -softmask -scodon 50 -i 30 -x 10 -n 30 -d 200000 -g T',
      wu_projection    => '-P wublast -gff -e #blast_eval# -c #blast_cov# -n 100 -x 5 ',
      ncbi_projection  => '-P blast -gff -e #blast_eval# -c #blast_cov# -W 3 -scodon 50 -i 30 -x 10 -n 30 -d 200000 -g T',
      );
    my %commandline_params = (
      'ncbi' => '-num_threads 3 -window_size 40',
      'wu' => '-cpus 3 -hitdist 40',
      'legacy_ncbi' => '-a 3 -A 40',
      );
    my $header_line = create_header_line($self->default_options->{'file_columns'});

    return [


###############################################################################
#
# ASSEMBLY LOADING ANALYSES
#
###############################################################################
      {
        # Creates a reference db for each species
        -logic_name => 'create_core_db',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveCreateDatabase',
        -parameters => {
                         'target_db'        => $self->o('core_db'),
                         'enscode_root_dir' => $self->o('enscode_root_dir'),
                         'create_type'      => 'core_only',
                       },
        -rc_name    => 'default',

        -flow_into  => {
                         1 => ['populate_production_tables'],
                       },

        -input_ids  => [
                        {
            assembly_name => $self->o('assembly_name'),
            assembly_accession => $self->o('assembly_accession'),
            assembly_refseq_accession => $self->o('assembly_refseq_accession'),
          },
        ],
      },

      {
        # Load production tables into each reference
        -logic_name => 'populate_production_tables',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HivePopulateProductionTables',
        -parameters => {
                         'target_db'        => $self->o('core_db'),
                         'output_path'      => $self->o('output_path'),
                         'enscode_root_dir' => $self->o('enscode_root_dir'),
                         'production_db'    => $self->o('production_db'),
                       },
        -rc_name    => 'default',

        -flow_into  => {
                         1 => WHEN ('#load_toplevel_only# == 1' => ['process_assembly_info'],
                                    '#load_toplevel_only# == 2' => ['custom_load_toplevel'])
                       },
      },

####
# Loading custom assembly where the user provide a FASTA file, probably a repeat library
####
     {
        -logic_name => 'custom_load_toplevel',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         cmd => 'perl '.catfile($self->o('enscode_root_dir'), 'ensembl-analysis', 'scripts', 'assembly_loading', 'load_seq_region.pl').
			              ' -dbhost '.$self->o('core_db_server').
                                      ' -dbuser '.$self->o('user').
                                      ' -dbpass '.$self->o('password').
                                      ' -dbport '.$self->o('core_db_port').
                                      ' -dbname '.$self->o('core_db_name').
                                      ' -coord_system_version '.$self->o('assembly_name').
	                              ' -default_version'.
                                      ' -coord_system_name primary_assembly'.
                                      ' -rank 1'.
                                      ' -fasta_file '. $self->o('custom_toplevel_file_path').
                                      ' -sequence_level'.
                                      ' -noverbose',
                       },
        -rc_name => '4GB',
        -flow_into => {
          1 => ['custom_set_toplevel'],
        },
      },


     {
        -logic_name => 'custom_set_toplevel',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         cmd => 'perl '.catfile($self->o('enscode_root_dir'), 'ensembl-analysis', 'scripts', 'assembly_loading', 'set_toplevel.pl').
                                      ' -dbhost '.$self->o('core_db_server').
                                      ' -dbuser '.$self->o('user').
                                      ' -dbpass '.$self->o('password').
                                      ' -dbport '.$self->o('core_db_port').
                                      ' -dbname '.$self->o('core_db_name'),
			       },
        -rc_name => 'default',
        -flow_into  => {
                         1 => ['custom_add_meta_keys'],
                       },
      },


      {
        -logic_name => 'custom_add_meta_keys',
        -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
        -parameters => {
          db_conn => $self->o('core_db'),
          sql => [
            'INSERT INTO meta (species_id,meta_key,meta_value) VALUES (1,"assembly.default","'.$self->o('assembly_name').'")',
            'INSERT INTO meta (species_id,meta_key,meta_value) VALUES (1,"assembly.name","'.$self->o('assembly_name').'")',
            'INSERT INTO meta (species_id,meta_key,meta_value) VALUES (1,"species.taxonomy_id","'.$self->o('taxon_id').'")',
          ],
        },
        -rc_name    => 'default',
        -flow_into => {
          1 => ['load_meta_info'],
        },
      },


####
# Loading assembly with only the toplevel sequences loaded, it fetches the data from INSDC databases
####
      {
        # Download the files and dir structure from the NCBI ftp site. Uses the link to a species in the ftp_link_file
        -logic_name => 'process_assembly_info',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveProcessAssemblyReport',
        -parameters => {
          full_ftp_path => $self->o('assembly_ftp_path'),
          output_path   => $self->o('output_path'),
          target_db     => $self->o('core_db'),
        },
        -rc_name    => '8GB',
       	-max_retry_count => 0,
        -flow_into  => {
          1 => ['load_meta_info'],
        },
      },

      {
        # Load some meta info and seq_region_synonyms
        -logic_name => 'load_meta_info',
        -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
        -parameters => {
          db_conn => $self->o('core_db'),
          sql => [
            'INSERT INTO meta (species_id, meta_key, meta_value) VALUES '.
              '(1, "species.stable_id_prefix", "'.$self->o('stable_id_prefix').'"),'.
              '(1, "species.url", "'.ucfirst($self->o('species_url')).'"),'.
              '(1, "species.division", "'.$self->o('species_division').'"),'.
              '(1, "genebuild.initial_release_date", NULL),'.
              '(1, "assembly.coverage_depth", "high"),'.
              '(1, "genebuild.id", '.$self->o('genebuilder_id').'),'.
              '(1, "genebuild.method", "full_genebuild"),'.
              '(1, "provider.name", "'.$self->o('provider_name').'"),'.
              '(1, "provider.url", "'.$self->o('provider_url').'"),'.
              '(1, "species.production_name", "'.$self->o('production_name').$self->o('production_name_modifier').'")'
          ],
        },
        -rc_name    => 'default',
        -flow_into  => {
          1 => ['load_taxonomy_info'],
                       },
      },


      {
        -logic_name => 'load_taxonomy_info',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveLoadTaxonomyInfo',
        -parameters => {
                         'target_db'        => $self->o('core_db'),
                         'taxonomy_db'      => $self->o('taxonomy_db'),
                       },
        -rc_name    => 'default',

        -flow_into  => {
          1 => ['fix_meta_info'],
        },
      },


      {
        # Load some meta info and seq_region_synonyms
        -logic_name => 'fix_meta_info',
        -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
        -parameters => {
          db_conn => $self->o('core_db'),
          sql => [
            'UPDATE meta SET meta_value="covid19" WHERE meta_key="species.common_name"',
            'UPDATE meta SET meta_value="Covid19" WHERE meta_key="species.display_name"',
          ],
        },
        -rc_name    => 'default',
        -flow_into  => {
                          1 => ['dump_softmasked_toplevel', 'fan_refseq_import'],
                       },
      },


###############################################################################
#
# REFSEQ ANNOTATION
#
###############################################################################
      {
        -logic_name => 'fan_refseq_import',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         cmd => 'if [ -n "#assembly_refseq_accession#" ]; then exit 0; else exit 42;fi',
                         return_codes_2_branches => {'42' => 2},
                       },
        -rc_name => 'default',
        -flow_into  => {
                          1 => ['load_refseq_synonyms'],
                       },
      },

      {
        -logic_name => 'load_refseq_synonyms',
        -module => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveLoadRefSeqSynonyms',
        -parameters => {
                         'target_db'        => $self->o('core_db'),
			 'output_dir'       => $self->o('output_path'),
			 'url'              => $self->o('refseq_report_ftp_path'),
                       },
        -rc_name => 'default',
#        -flow_into  => {
#                          1 => ['download_refseq_gff'],
#                       },
      },


#      {
#        -logic_name => 'download_refseq_gff',
#        -module => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveDownloadData',
#        -parameters => {
#          output_dir => catdir($self->o('output_path'), 'refseq_import'),
#          url => $self->o('refseq_import_ftp_path'),
#          download_method => 'ftp',
#        },
#        -rc_name => 'default',
#        -flow_into  => {
#                         1 => ['create_refseq_db'],
#                       },
#      },


#      {
#        -logic_name => 'create_refseq_db',
#        -module => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveCreateDatabase',
#        -parameters => {
#                         source_db => $self->o('dna_db'),
#                         target_db => $self->o('refseq_db'),
#                         create_type => 'clone',
#                       },
#       -rc_name => 'default',
#       -flow_into  => {
#                          1 => ['load_refseq_gff'],
#                      },
#      },

 #     {
 #       -logic_name => 'load_refseq_gff',
 #       -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
 #       -parameters => {
 #                        cmd => 'perl '.$self->o('refseq_import_script_path').
 #                                     ' -dnahost '.$self->o('dna_db','-host').
 #                                     ' -dnadbname '.$self->o('dna_db','-dbname').
 #                                     ' -dnaport '.$self->o('dna_db','-port').
 #                                     ' -dnauser '.$self->o('dna_db','-user').
 #                                     ' -user '.$self->o('user').
 #                                     ' -pass '.$self->o('password').
 #                                     ' -host '.$self->o('refseq_db','-host').
 #                                     ' -port '.$self->o('refseq_db','-port').
 #                                     ' -dbname '.$self->o('refseq_db','-dbname').
 #                                     ' -write'.
 #                                     ' -file '.catfile($self->o('output_path'), 'refseq_import', '#assembly_refseq_accession#_#assembly_name#_genomic.gff'),
 #                      },
 #       -rc_name => 'refseq_import',
 #     },

      {
        # Set the toplevel
        -logic_name => 'dump_softmasked_toplevel',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveDumpGenome',
        -parameters => {
                         'coord_system_name'    => 'toplevel',
                         'target_db'            => $self->o('core_db'),
                         'output_path'          => $self->o('genome_dumps'),
                         'enscode_root_dir'     => $self->o('enscode_root_dir'),
                         'species_name'         => $self->o('species_name'),
                         'repeat_logic_names'   => [],
                       },
        -flow_into => {
          1 => ['format_softmasked_toplevel'],
        },
        -rc_name    => '3GB',
      },


      {
        # This should probably be a proper module
        -logic_name => 'format_softmasked_toplevel',
        -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         'cmd'    => 'if [ "'.$self->o('blast_type').'" = "ncbi" ]; then convert2blastmask -in '.$self->o('softmasked_genome_file').' -parse_seqids -masking_algorithm repeatmasker -masking_options "repeatmasker, default" -outfmt maskinfo_asn1_bin -out '.$self->o('softmasked_genome_file').'.asnb;makeblastdb -in '.$self->o('softmasked_genome_file').' -dbtype nucl -parse_seqids -mask_data '.$self->o('softmasked_genome_file').'.asnb -title "'.$self->o('species_name').'"; else xdformat -n '.$self->o('softmasked_genome_file').';fi',
                       },
        -rc_name    => '5GB',
        -flow_into => {
          1 => ['create_faidx'],
        },
      },


      {
        -logic_name => 'create_faidx',
        -module     => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -rc_name => '5GB',
        -parameters => {
          cmd => 'if [ ! -e "'.$self->o('softmasked_genome_file').'.fai" ]; then '.$self->o('samtools_path').' faidx '.$self->o('softmasked_genome_file').';fi',
        },

        -flow_into  => {
          1 => ['exonerate_viral_proteins'],
        },

      },


      {
        -logic_name => 'exonerate_viral_proteins',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveExonerate2Genes',
        -parameters => {
          logic_name => 'ensembl',
          iid_type => 'filename',
          protein_file => $self->o('protein_file'),
          dna_db => $self->o('dna_db'),
          target_db => $self->o('core_db'),
          output_biotype => 'protein_coding',
          %{get_analysis_settings('Bio::EnsEMBL::Analysis::Hive::Config::ExonerateStatic','exonerate_protein')},
          genome_file      => $self->o('softmasked_genome_file'),
          exonerate_path   => $self->o('exonerate_path'),
          calculate_coverage_and_pid => $self->o('target_exonerate_calculate_coverage_and_pid'),
        },
        -rc_name          => '3GB',
        -flow_into => {
          '1' => ['process_covid_transcripts'],
        },
      },


      {
        -logic_name => 'process_covid_transcripts',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::ProcessCovid19Genes',
        -parameters => {
                         'target_db' => $self->o('core_db'),
                       },
        -rc_name    => 'default',
        -flow_into  => {
                          1 => ['run_stable_ids'],
                       },
      },


      {
        -logic_name => 'run_stable_ids',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::SetStableIDs',
        -parameters => {
                         enscode_root_dir => $self->o('enscode_root_dir'),
                         mapping_required => $self->o('mapping_required'),
                         target_db => $self->o('core_db'),
                         id_start => $self->o('stable_id_prefix').$self->o('stable_id_start'),
                         output_path => $self->o('output_path'),
                       },
        -rc_name    => 'default',
        -flow_into  => {
                       1 => ['set_meta_coords'],
        },
      },


      {
        -logic_name => 'set_meta_coords',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         cmd => 'perl '.$self->o('meta_coord_script').
                                ' -user '.$self->o('user').
                                ' -pass '.$self->o('password').
                                ' -host '.$self->o('core_db','-host').
                                ' -port '.$self->o('core_db','-port').
                                ' -dbpattern '.$self->o('core_db','-dbname')
                       },
        -rc_name => 'default',
        -flow_into => {
                        1 => ['set_meta_levels'],
                      },
      },


      {
        -logic_name => 'set_meta_levels',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         cmd => 'perl '.$self->o('meta_levels_script').
                                ' -user '.$self->o('user').
                                ' -pass '.$self->o('password').
                                ' -host '.$self->o('core_db','-host').
                                ' -port '.$self->o('core_db','-port').
                                ' -dbname '.$self->o('core_db','-dbname')
                       },
        -rc_name => 'default',
        -flow_into => { 1 => ['set_canonical_transcripts'] },
      },


      {
        -logic_name => 'set_canonical_transcripts',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         cmd => 'perl '.$self->o('select_canonical_script').
                                ' -dbuser '.$self->o('user').
                                ' -dbpass '.$self->o('password').
                                ' -dbhost '.$self->o('core_db','-host').
                                ' -dbport '.$self->o('core_db','-port').
                                ' -dbname '.$self->o('core_db','-dbname').
                                ' -coord toplevel -write'
                       },
        -rc_name => '10GB',
        -flow_into => { 1 => ['null_columns'] },
      },


      {
        -logic_name => 'null_columns',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SqlCmd',
        -parameters => {
          db_conn => $self->o('core_db'),
          sql => [
            'UPDATE transcript set stable_id = NULL',
            'UPDATE translation set stable_id = NULL',
            'UPDATE exon set stable_id = NULL',
            'UPDATE protein_align_feature set external_db_id = NULL',
            'UPDATE dna_align_feature set external_db_id = NULL',
          ],
        },
        -rc_name    => 'default',
        -flow_into => {
                        1 => ['load_external_db_ids_and_optimise_af_tables'],
                      },
      },


      {
        -logic_name => 'load_external_db_ids_and_optimise_af_tables',
        -module => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
        -parameters => {
                         cmd => 'perl '.$self->o('load_optimise_script').
                                ' -output_path '.catdir($self->o('output_path'), 'optimise').
                                ' -uniprot_filename '.$self->o('protein_entry_loc').
                                ' -dbuser '.$self->o('user').
                                ' -dbpass '.$self->o('password').
                                ' -dbport '.$self->o('core_db','-port').
                                ' -dbhost '.$self->o('core_db','-host').
                                ' -dbname '.$self->o('core_db','-dbname').
                                ' -prod_dbuser '.$self->o('user_r').
                                ' -prod_dbhost '.$self->o('production_db','-host').
                                ' -prod_dbname '.$self->o('production_db','-dbname').
                                ' -prod_dbport '.$self->o('production_db','-port').
                                ' -ise -core'
                       },
        -max_retry_count => 0,
        -rc_name => '8GB',
#        -flow_into => {
#                        1 => ['clean_unused_analyses'],
#                      },
      },


    ];
}


sub resource_classes {
  my $self = shift;

  return {
    '1GB' => { LSF => $self->lsf_resource_builder('production-rh74', 1000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '2GB' => { LSF => $self->lsf_resource_builder('production-rh74', 2000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '3GB' => { LSF => $self->lsf_resource_builder('production-rh74', 3000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '4GB' => { LSF => $self->lsf_resource_builder('production-rh74', 4000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '5GB' => { LSF => $self->lsf_resource_builder('production-rh74', 5000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '6GB' => { LSF => $self->lsf_resource_builder('production-rh74', 6000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '6GB_registry' => { LSF => [$self->lsf_resource_builder('production-rh74', 6000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}]), '-reg_conf '.$self->default_options->{registry_file}]},
    '7GB' => { LSF => $self->lsf_resource_builder('production-rh74', 7000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '8GB' => { LSF => $self->lsf_resource_builder('production-rh74', 8000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '9GB' => { LSF => $self->lsf_resource_builder('production-rh74', 9000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '10GB' => { LSF => $self->lsf_resource_builder('production-rh74', 10000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '15GB' => { LSF => $self->lsf_resource_builder('production-rh74', 15000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '20GB' => { LSF => $self->lsf_resource_builder('production-rh74', 20000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '25GB' => { LSF => $self->lsf_resource_builder('production-rh74', 25000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '30GB' => { LSF => $self->lsf_resource_builder('production-rh74', 30000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '35GB' => { LSF => $self->lsf_resource_builder('production-rh74', 35000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '40GB' => { LSF => $self->lsf_resource_builder('production-rh74', 40000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '50GB' => { LSF => $self->lsf_resource_builder('production-rh74', 50000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '75GB' => { LSF => $self->lsf_resource_builder('production-rh74', 75000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '80GB' => { LSF => $self->lsf_resource_builder('production-rh74', 80000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '100GB' => { LSF => $self->lsf_resource_builder('production-rh74', 100000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'default' => { LSF => $self->lsf_resource_builder('production-rh74', 900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'repeatmasker' => { LSF => $self->lsf_resource_builder('production-rh74', 2900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'repeatmasker_rebatch' => { LSF => $self->lsf_resource_builder('production-rh74', 5900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'simple_features' => { LSF => $self->lsf_resource_builder('production-rh74', 2900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'genscan' => { LSF => $self->lsf_resource_builder('production-rh74', 3900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'genscan_short' => { LSF => $self->lsf_resource_builder('production-rh74', 5900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'blast' => { LSF => $self->lsf_resource_builder('production-rh74', 2900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], undef, 3)},
    'blast10GB' => { LSF => $self->lsf_resource_builder('production-rh74', 10000, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], undef, 3)},
    'blast_retry' => { LSF => $self->lsf_resource_builder('production-rh74', 5900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'dna_db_server'}], undef, 3)},
    'genblast' => { LSF => $self->lsf_resource_builder('production-rh74', 3900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'exonerate_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'genblast_retry' => { LSF => $self->lsf_resource_builder('production-rh74', 4900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'exonerate_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'project_transcripts' => { LSF => $self->lsf_resource_builder('production-rh74', 7200, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'projection_db_server'}, $self->default_options->{'projection_lastz_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'refseq_import' => { LSF => $self->lsf_resource_builder('production-rh74', 9900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'refseq_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'layer_annotation' => { LSF => $self->lsf_resource_builder('production-rh74', 3900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'exonerate_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'genebuilder' => { LSF => $self->lsf_resource_builder('production-rh74', 1900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'exonerate_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'transcript_finalisation' => { LSF => $self->lsf_resource_builder('production-rh74', 1900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'exonerate_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    'filter' => { LSF => $self->lsf_resource_builder('production-rh74', 4900, [$self->default_options->{'pipe_db_server'}, $self->default_options->{'exonerate_db_server'}, $self->default_options->{'dna_db_server'}], [$self->default_options->{'num_tokens'}])},
    '2GB_multithread' => { LSF => $self->lsf_resource_builder('production-rh74', 2000, [$self->default_options->{'pipe_db_server'}], undef, $self->default_options->{'use_threads'})},
    '3GB_merged_multithread' => { LSF => $self->lsf_resource_builder('production-rh74', 3000, [$self->default_options->{'pipe_db_server'}], undef, $self->default_options->{'rnaseq_merge_threads'})},
    '5GB_merged_multithread' => { LSF => $self->lsf_resource_builder('production-rh74', 5000, [$self->default_options->{'pipe_db_server'}], undef, ($self->default_options->{'rnaseq_merge_threads'}))},
    '5GB_multithread' => { LSF => $self->lsf_resource_builder('production-rh74', 5000, [$self->default_options->{'pipe_db_server'}], undef, ($self->default_options->{'use_threads'}+1))},
    '10GB_multithread' => { LSF => $self->lsf_resource_builder('production-rh74', 10000, [$self->default_options->{'pipe_db_server'}], undef, ($self->default_options->{'use_threads'}+1))},
    '20GB_multithread' => { LSF => $self->lsf_resource_builder('production-rh74', 20000, [$self->default_options->{'pipe_db_server'}], undef, ($self->default_options->{'use_threads'}+1))},
  }
}

sub hive_capacity_classes {
  my $self = shift;

  return {
           'hc_low'    => 200,
           'hc_medium' => 500,
           'hc_high'   => 1000,
         };
}


sub check_file_in_ensembl {
  my ($self, $file_path) = @_;
  push @{$self->{'_ensembl_file_paths'}}, $file_path;
  return $self->o('enscode_root_dir').'/'.$file_path;
}

1;