=head1 LICENSE
# Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# Copyright [2016-2022] EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

  Questions may also be sent to the Ensembl help desk at
  <http://www.ensembl.org/Help/Contact>.

=cut

=head1 NAME

Bio::EnsEMBL::Analysis::RunnableDB::Genscan - 

=head1 SYNOPSIS

  my $runnabledb = Bio::EnsEMBL::Analysis::RunnableDB::Genscan->
  new(
      -input_id => 'contig::AL805961.22.1.166258:1:166258:1',
      -db => $db,
      -analysis => $analysis,
     );
  $runnabledb->fetch_input;
  $runnabledb->run;
  $runnabledb->write_output;


=head1 DESCRIPTION

fetches sequence data from database an instantiates and runs the
genscan runnable


=head1 METHODS

=cut

package Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveGenscan;

use strict;
use warnings;
use feature 'say';

use Bio::EnsEMBL::Analysis;
use Bio::EnsEMBL::Analysis::Runnable::Genscan;

use parent ('Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveBaseRunnableDB');


=head2 fetch_input

  Arg [1]   : Bio::EnsEMBL::Analysis::RunnableDB::Genscan
  Function  : fetch data out of database and create runnable
  Returntype: 1
  Exceptions: none
  Example   :

=cut


sub fetch_input{
  my ($self) = @_;

  $self->setup_fasta_db;
  my $repeat_masking = $self->param('repeat_masking_logic_names');
  my $dba = $self->get_database_by_name('target_db');
  my $pta = $dba->get_PredictionTranscriptAdaptor();
  $self->get_adaptor($pta);

  $self->hrdb_set_con($dba,'target_db');

  my $slice_array = $self->param('iid');
  unless(ref($slice_array) eq "ARRAY") {
    $self->throw("Expected an input id to be an array reference. Type found: ".ref($slice_array));
  }

  my $analysis = Bio::EnsEMBL::Analysis->new(
                                              -logic_name => $self->param('logic_name'),
                                              -module => $self->param('module'),
                                              -program_file => $self->param('genscan_path'),
                                              -db => 'HumanIso.smat',
                                              -db_file => $self->param('genscan_matrix_path'),
                                            );

  $self->analysis($analysis);

  my %parameters;
  if($self->parameters_hash){
    %parameters = %{$self->parameters_hash};
  }

  foreach my $slice_name (@{$slice_array}) {
    my $slice = $self->fetch_sequence($slice_name,$dba,$repeat_masking);
    my $seq = $slice->seq;
    if ($seq =~ /[CATG]{3}/) {
     $self->input_is_void(0);
    } else {
      $self->input_is_void(1);
      $self->warning("Need at least 3 nucleotides - maybe your sequence was fully repeatmasked ...");
      next;
    }

    my $runnable = Bio::EnsEMBL::Analysis::Runnable::Genscan->new
                   (
                     -query    => $slice,
                     -program  => $analysis->program_file(),
                     -analysis => $analysis,
                     -matrix   => $analysis->db_file,
                     %parameters,
                   );
    $self->runnable($runnable);
  }

  unless(scalar(@{$self->runnable()})) {
    $self->input_job->autoflow(0);
    $self->complete_early('No input seq to process');
  }

  return 1;
}


sub run {
  my ($self) = @_;

  foreach my $runnable(@{$self->runnable}){
    eval {
      $runnable->run;
    };
    if ($@) {
      $self->dataflow_output_id(undef,-3);
      $self->complete_early("FAILED to run, and I will die now... check your runnable!!". $@);
    } else {
      print "command was fine\n";
    }
    $self->output($runnable->output);
  }

  return 1;
}


=head2 get_adaptor

  Arg [1]   : Bio::EnsEMBL::Analysis::RunnableDB::Genscan
  Arg [2]   : Bio::EnsEMBL::DBSQL::PredictionTranscriptAdaptor
  Function  : get/set repeatfeature adaptor
  Returntype: Bio::EnsEMBL::DBSQL::PredictionTranscriptAdaptor
  Exceptions: none
  Example   :

=cut

sub get_adaptor {
  my ($self,$pta) = @_;
  if($pta) {
    $self->param('_pta',$pta);
  }

  return($self->param('_pta'));
}

1;
