=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2017] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 CONTACT

Please email comments or questions to the public Ensembl
developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

Questions may also be sent to the Ensembl help desk at
<http://www.ensembl.org/Help/Contact>.

=head1 NAME

Bio::EnsEMBL::Analysis::Hive::Config::LayerAnnotationStatic

=head1 SYNOPSIS

use Bio::EnsEMBL::Analysis::Tools::Utilities qw(get_analysis_settings);
use parent ('Bio::EnsEMBL::Analysis::Hive::Config::HiveBaseConfig_conf');

sub pipeline_analyses {
    my ($self) = @_;

    return [
      {
        -logic_name => 'run_uniprot_blast',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveBlastGenscanPep',
        -parameters => {
                         blast_db_path => $self->o('uniprot_blast_db_path'),
                         blast_exe_path => $self->o('uniprot_blast_exe_path'),
                         commandline_params => '-cpus 3 -hitdist 40',
                         repeat_masking_logic_names => ['repeatmasker_'.$self->o('repeatmasker_library')],
                         prediction_transcript_logic_names => ['genscan'],
                         iid_type => 'feature_id',
                         logic_name => 'uniprot',
                         module => 'HiveBlastGenscanPep',
                         get_analysis_settings('Bio::EnsEMBL::Analysis::Hive::Config::GenebuilderStatic',$self->o('uniprot_set'),
                      },
        -flow_into => {
                        -1 => ['run_uniprot_blast_himem'],
                        -2 => ['run_uniprot_blast_long'],
                      },
        -rc_name    => 'blast',
      },
  ];
}

=head1 DESCRIPTION

This is the config file for all layer annotation analysis. You should use it in your Hive configuration file to
specify the parameters of an analysis. You can either choose an existing config or you can create
a new one based on the default hash.

=head1 METHODS

  _master_config_settings: contains all possible parameters

=cut

package Bio::EnsEMBL::Analysis::Hive::Config::LayerAnnotationStatic;

use strict;
use warnings;

use parent ('Bio::EnsEMBL::Analysis::Hive::Config::BaseStatic');

sub _master_config {
  my ($self, $key) = @_;

  my %config = (
    default => [],
    primates_basic => [
             {
              ID         => 'LAYER1',
              BIOTYPES   => [
                             'realign_95',
                             'realign_80',
                             'rnaseq_95',
                             'rnaseq_80',
                             'self_pe12_sp_95',
                             'self_pe12_tr_95',
                             'self_pe12_sp_80',
                             'self_pe12_tr_80',
                             'human_pe12_sp_95',
                             'human_pe12_tr_95',
                             'primates_pe12_sp_95',
                             'primates_pe12_tr_95',
                             'mammals_pe12_sp_95',
                             'mammals_pe12_tr_95',
                            ],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER2',
              BIOTYPES   => [
                             'human_pe12_sp_80',
                             'human_pe12_tr_80',
                             'primates_pe12_sp_80',
                             'primates_pe12_tr_80',
                             'mammals_pe12_sp_80',
                             'mammals_pe12_tr_80',
                            ],
              FILTER_AGAINST => ['LAYER1'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER3',
              BIOTYPES   => [
                             'primates_pe3_sp_95',
                             'vert_pe12_sp_95',
                             'vert_pe12_tr_95',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER4',
              BIOTYPES   => [
                             'primates_pe3_sp_80',
                             'vert_pe12_sp_80',
                             'vert_pe12_tr_80',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2','LAYER3'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER5',
              BIOTYPES   => [
                              'realign_50',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2','LAYER3','LAYER4'],
              DISCARD    => 0,
            },


    ],

    rodents_basic => [
             {
              ID         => 'LAYER1',
              BIOTYPES   => ['realign_95',
                             'rnaseq_95',
                             'rnaseq_80',
                             'self_pe12_sp_95',
                             'self_pe12_sp_80',
                             'mouse_pe12_sp_95',
                             'rodents_pe12_sp_95',
                             'human_pe12_sp_95',
                            ],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER2',
              BIOTYPES   => ['self_pe12_tr_95',
                             'mouse_pe12_tr_95',
                             'rodents_pe12_tr_95',
                             'human_pe12_tr_95',
                            ],
              FILTER_AGAINST => ['LAYER1'],
              DISCARD    => 0,

            },

             {
              ID         => 'LAYER3',
              BIOTYPES   => ['realign_80',
                             'mouse_pe12_sp_80',
                             'rodents_pe12_sp_80',
                             'human_pe12_sp_80',
                             'mammals_pe12_sp_95',
                             'vert_pe12_sp_95',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER4',
              BIOTYPES   => ['self_pe12_tr_80',
                             'mouse_pe12_tr_80',
                             'rodents_pe12_tr_80',
                             'human_pe12_tr_80',
                             'mammals_pe12_tr_95',
                             'vert_pe12_tr_95',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2','LAYER3'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER5',
              BIOTYPES   => ['rodents_pe3_sp_95',
                             'rodents_pe3_tr_95',
                             'mammals_pe12_sp_80',
                             'vert_pe12_sp_80',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2','LAYER3','LAYER4'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER6',
              BIOTYPES   => ['realign_50',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2','LAYER3','LAYER4','LAYER5'],
              DISCARD    => 0,
            },
    ],

    mammals_basic => [
             {
              ID         => 'LAYER1',
              BIOTYPES   => [
                             'realign_95',
                             'realign_80',
                             'rnaseq_95',
                             'rnaseq_80',
                             'self_pe12_sp_95',
                             'self_pe12_tr_95',
                             'self_pe12_sp_80',
                             'self_pe12_tr_80',
                             'human_pe12_sp_95',
                             'human_pe12_tr_95',
                             'mouse_pe12_sp_95',
                             'mouse_pe12_tr_95',
                             'mammals_pe12_sp_95',
                             'mammals_pe12_tr_95',
                            ],
              DISCARD    => 0,
            },

            {
              ID         => 'LAYER2',
              BIOTYPES   => [
                             'human_pe12_sp_80',
                             'human_pe12_tr_80',
                             'mouse_pe12_sp_80',
                             'mouse_pe12_tr_80',
                             'self_pe3_sp_95',
                             'self_pe3_tr_95',
                             'mammals_pe12_sp_80',
                             'mammals_pe12_tr_80',
                             'vert_pe12_sp_95',
                             'vert_pe12_tr_95',
                            ],
              FILTER_AGAINST => ['LAYER1'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER3',
              BIOTYPES   => [
                             'vert_pe12_sp_80',
                             'vert_pe12_tr_80',
                             'realign_50',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2'],
              DISCARD    => 0,
            },

    ],

    fish_basic => [
             {
              ID         => 'LAYER1',
              BIOTYPES   => [
                             'realign_95',
                             'realign_80',
                             'rnaseq_95',
                             'rnaseq_80',
                             'self_pe12_sp_95',
                             'self_pe12_tr_95',
                             'self_pe12_sp_80',
                             'self_pe12_tr_80',
                             'fish_pe12_sp_95',
                             'fish_pe12_tr_95',
                            ],
              DISCARD    => 0,
            },

            {
              ID         => 'LAYER2',
              BIOTYPES   => [
                             'fish_pe12_sp_80',
                             'fish_pe12_tr_80',
                             'human_pe12_sp_95',
                             'human_pe12_tr_95',
                             'mouse_pe12_sp_95',
                             'mouse_pe12_tr_95',
                             'self_pe3_sp_95',
                             'self_pe3_tr_95',
                             'vert_pe12_sp_95',
                             'vert_pe12_tr_95',
                            ],
              FILTER_AGAINST => ['LAYER1'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER3',
              BIOTYPES   => [
                             'human_pe12_sp_80',
                             'human_pe12_tr_80',
                             'mouse_pe12_sp_80',
                             'mouse_pe12_tr_80',
                             'vert_pe12_sp_80',
                             'vert_pe12_tr_80',
                             'mammals_pe12_sp_95',
                             'mammals_pe12_tr_95',
                             'mammals_pe12_sp_80',
                             'mammals_pe12_tr_80',
                             'realign_50',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2'],
              DISCARD    => 0,
            },

    ],

    fish_complete => [
             {
              ID         => 'LAYER1',
              BIOTYPES   => [
                             'realign_95',
                             'realign_80',
                             'rnaseq_95',
                             'rnaseq_80',
                             'self_pe12_sp_95',
                             'self_pe12_tr_95',
                             'self_pe12_sp_80',
                             'self_pe12_tr_80',
                             'fish_pe12_sp_95',
                             'fish_pe12_tr_95',
                            ],
              DISCARD    => 0,
            },

            {
              ID         => 'LAYER2',
              BIOTYPES   => [
                             'fish_pe12_sp_80',
                             'fish_pe12_tr_80',
                             'human_pe12_sp_95',
                             'human_pe12_tr_95',
                             'mouse_pe12_sp_95',
                             'mouse_pe12_tr_95',
                             'self_pe3_sp_95',
                             'self_pe3_tr_95',
                             'vert_pe12_sp_95',
                             'vert_pe12_tr_95',
                            ],
              FILTER_AGAINST => ['LAYER1'],
              DISCARD    => 0,
            },

             {
              ID         => 'LAYER3',
              BIOTYPES   => [
                             'human_pe12_sp_80',
                             'human_pe12_tr_80',
                             'mouse_pe12_sp_80',
                             'mouse_pe12_tr_80',
                             'vert_pe12_sp_80',
                             'vert_pe12_tr_80',
                             'mammals_pe12_sp_95',
                             'mammals_pe12_tr_95',
                             'mammals_pe12_sp_80',
                             'mammals_pe12_tr_80',
                             'realign_50',
                            ],
              FILTER_AGAINST => ['LAYER1','LAYER2'],
              DISCARD    => 0,
            },

    ],
  );
  return $config{$key};
}


1;

