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

# holds the object that does the second round of filtering

package Bio::EnsEMBL::Pipeline::Tools::Pmatch::Second_PMF;

use warnings ;
use strict ;

use Bio::EnsEMBL::Utils::Argument qw (rearrange);

sub new {
  my ($class, @args) = @_;
  my $self = bless {}, $class;

  my ($phits) = rearrange(['PHITS'], @args);

  $self->throw("No pmatch hits data") unless defined $phits;
  $self->phits($phits);

  #print STDERR "SECOND  PMF\n";
  #foreach my $hit(@$phits){
  #print STDERR $hit->chr_name  . ":" .$hit->qstart . "," .$hit->qend   . ":" . $hit->protein_id . ":" .$hit->coverage . "\n";
  #}
  #print STDERR "SECOND PMF\n";
  my %proteins = (); # hash of arrays of MergedHits, indexed by protin name
  $self->{_proteins} = \%proteins;

  return $self;

}

sub phits {
  my ($self, $phits) = @_;
  
  # $phits is an array reference
  if(defined($phits)){
    if (ref($phits) eq "ARRAY") {
      $self->{_phits} = $phits;
    } 
    else {
      $self->throw("[$phits] is not an array ref.");
    }
  }
     
  return $self->{_phits};

}

sub run {
  my ($self) = @_;

  # group hits by protein

  my %prots = %{$self->{_proteins}}; # just makes it a bit easier to follow

  foreach my $hit(@{$self->phits}){
    # print the details of all the constituent coord pairs separated by white space 
    push (@{$prots{$hit->protein_id}}, $hit);
  }

  $self->{_proteins} = \%prots;

  # prune and store the hits
  $self->prune_hits;

}

sub prune_hits {
  my ($self) = @_;  
  my %prots = %{$self->{_proteins}}; # just makes it a bit easier to follow  

  PROTEIN:
  foreach my $p(keys %prots){
    my @chosen = ();
    my @allhits = @{$prots{$p}};
    
    # sort by descending order of coverage
    @allhits = sort {$b->coverage <=> $a->coverage} @allhits;
    
    my $first = shift(@allhits);
    
    # don't select any hits that have coverage less than 2% below that of the first hit, be it 100 or 99.9 or ...
    my $curr_pc = $first->coverage() - 2; 
    
    # lower bound threshold - reject anything with < 25% coverage
    my $lower_threshold = 25;
    next PROTEIN if $first->coverage < $lower_threshold;
    
    push (@chosen,$first) unless $first->coverage < $lower_threshold;
  PRUNE:
    foreach my $hit(@allhits) {
      
      last PRUNE if $hit->coverage() < $curr_pc;
      last PRUNE if $hit->coverage() < $lower_threshold;
      push (@chosen,$hit);
    }
    
    push(@{$self->{_output}},@chosen);
  }
  
}

sub output {
  my ($self) = @_;
  if (!defined($self->{_output})) {
    $self->{_output} = [];
  } 
  return @{$self->{_output}};
}

1;
