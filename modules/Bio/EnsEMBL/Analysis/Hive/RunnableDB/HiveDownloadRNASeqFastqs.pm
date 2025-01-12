=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2022] EMBL-European Bioinformatics Institute

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

Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveDownloadRNASeqFastqs

=head1 SYNOPSIS


=head1 DESCRIPTION


=cut

package Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveDownloadRNASeqFastqs;

use warnings;
use strict;
use feature 'say';

use parent ('Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveBaseRunnableDB');

sub param_defaults {
  my ($self) = @_;

  return {
	  %{$self->SUPER::param_defaults},
    decompress => 0,
    create_faidx => 0,
  }
}

sub write_output {
  my ($self) = @_;
  my $ftp_base_url = $self->param('ftp_base_url');
  my $fastq = $self->param('iid');
  my $path = $self->param('input_dir');
  my $srr;

  if(-e $path.'/'.$fastq) {
    if($self->param('decompress')) {
      $fastq = $self->decompress($path,$fastq);
    }

    if($self->param('create_faidx')) {
      $self->create_faidx($path,$fastq);
    }

    $self->complete_early('Input file already exists, will not download');
  }

  if ($fastq =~ m/_/){
    $srr = (split /_/, $fastq)[0];
  }
  else{
    $srr = (split /\./, $fastq)[0];
  }
  my $first = substr $srr, 0, 6;
  my $second_a = '00'.(substr $srr, -1, 1);
  my $second_b ='0'.(substr $srr, -2, 2);

  my $exit_code = 0;
  my $wget_cmd_list = [['wget', '-c', '-qq', "$ftp_base_url/$first/$second_a/$srr/$fastq", '-P', $path],['wget', '-c', '-qq', "$ftp_base_url/$first/$second_b/$srr/$fastq", '-P', $path],['wget', '-c', '-qq', "$ftp_base_url/$first/$srr/$fastq", '-P', $path]];
  foreach my $wget_cmd (@$wget_cmd_list){
    $exit_code = $self->exit_code_test($wget_cmd);
    if ($exit_code){
      last;
    }
  }
  if (!$exit_code){
    if (-e $path.'/'.$fastq) {
      $self->run_system_command(['rm',"$path/$fastq"]);
    }
    $self->throw("Failed to download $fastq");
  }

  unless(-e $path.'/'.$fastq) {
    $self->throw("Did not find the fastq file on the expected path. Path:\n".$path."/".$fastq);
  }

  if($self->param('decompress')) {
    $fastq = $self->decompress($path,$fastq);
  }

  if($self->param('create_faidx')) {
    $self->create_faidx($path,$fastq);
  }
}

sub decompress {
  my ($self,$path,$fastq) = @_;
  my $cmd = 'gunzip '.$path.'/'.$fastq;

  # Remove this in case indexing in the code block after this one
  if($fastq =~ s/\.gz$//) {
    my $gunzip_res = system($cmd);
    if($gunzip_res) {
      $self->throw("Failed to decompress file. Command:\n".$cmd);
    }
  } else {
    $self->warning("You selected decompress, but the file did not have a .gz extension, so will not try and decompress");
  }

  # Update these in case the extension was removed
  $self->param('iid',$fastq);
  $self->param('fastq_file',$fastq);

  return($fastq);
}


sub create_faidx {
  my ($self,$path,$fastq) = @_;

  if(-e $path.'/'.$fastq.'.fai') {
    $self->warning("You selected faidx, but the faidx exists, so will not try and create");
    return;
  }

  my $cmd = $self->param_required('samtools_path').' faidx '.$path.'/'.$fastq;
  my $faidx_res = system($cmd);
  if($faidx_res) {
    $self->throw("Failed to index file. Command:\n".$cmd);
  }
}

=head2 exit_code_test

  Arg [1]    : Array, wget command
               e.g. ['wget', '-qq', "$ftp_base_url/$first/$second_a/$srr/$fastq",  '-P', $path]
  Description: The run_system_command returns a different exit code to wget
               Here, run_system_command exit code is bit-shifted and tested (wget exit code for server error is 8)
  Returntype : Boolean
  Exceptions : Warning if error code not 8

=cut

sub exit_code_test {
  my ($self,$wget_cmd) = @_;

  my $res = $self->run_system_command($wget_cmd);
  if ($res) {
    $res >>= 8;
    $self->warning("wget died with error code $res");
    return 0;
  } else {
    return 1;
  }

}


1;
