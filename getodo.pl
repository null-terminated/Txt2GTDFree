#!/bin/perl
use XML::Simple;
use Config::Properties;

open PROPS, "< config.properties"
	|| die "unable to open configuration file";
my $properties = new Config::Properties();
$properties->load(*PROPS);

my $fileGtdFree = $properties->getProperty('GTDFREEXML');
my $fileTodo = $properties->getProperty('TODOTXT');
my $fileDone = $properties->getProperty('DONETXT');

my $xs1 = XML::Simple->new();

my $doc = $xs1->XMLin($fileGtdFree);

my @projid; # Array de IDs de projetos
my @projnm; # Array de Nomes de projetos

open(TODO,">$fileTodo")
	|| die("Nao foi possivel abrir arquivo Todo");
open(DONE,">$fileDone")
	|| die("Nao foi possivel abrir arquivo Done");

# transforma o no do XML em um Hash e obtem suas chaves
foreach my $key (keys (%{$doc->{projects}->{project}})) {
	push(@projid,$doc->{projects}->{project}->{$key}->{'id'});
	push(@projnm,$key);
}

# Transforma os Arrays em um Hash
my %projs = ();
@projs{@projid} = @projnm;

# Ler o no XML como um Hash 
foreach my $key (keys (%{$doc->{lists}->{list}})) {
	# Para as listas que so possuem uma Action 	
	if ($doc->{lists}->{list}->{$key}->{action}->{'description'}) {
		$proj = $doc->{lists}->{list}->{$key}->{action}->{'project'};
		$queued = $doc->{lists}->{list}->{$key}->{action}->{'queued'};

		if ($doc->{lists}->{list}->{$key}->{action}->{'resolution'} eq "OPEN") { 
			if ($key eq "In-Bucket") {
				print TODO ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{'description'} . "\n";
			} else {
				print TODO $key . " " . ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{'description'} . "\n";
			}
		} elsif ($doc->{lists}->{list}->{$key}->{action}->{'resolution'} eq "RESOLVED") {
			$rtimeaux = $doc->{lists}->{list}->{$key}->{action}->{'resolved'}; 
			$rtime = substr($rtimeaux,0,10);
			($Second, $Minute, $Hour, $DayAux, $MonthAux, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime($rtime);	
			$Year += 1900;
			$MonthAux++;

			$Day = substr(($DayAux + 100),1,2);
			$Month = substr(($MonthAux + 100),1,2);

			if ($key eq "In-Bucket") {
				print DONE "x $Year-$Month-$Day " . ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{'description'} . "\n";
			} else {
				print DONE "x $Year-$Month-$Day " . $key . " " . ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{'description'} . "\n"; 
			}
		}
	}
	
	# Para as listas que possuem mais de uma Action
	foreach my $key1 (keys (%{$doc->{lists}->{list}->{$key}->{action}})) {
		if ($doc->{lists}->{list}->{$key}->{action}->{$key1}->{'description'})  { 
			$proj = $doc->{lists}->{list}->{$key}->{action}->{$key1}->{'project'};
			$queued = $doc->{lists}->{list}->{$key}->{action}->{$key1}->{'queued'};

			if ($doc->{lists}->{list}->{$key}->{action}->{$key1}->{'resolution'} eq "OPEN") { 
				if ($key eq "In-Bucket") {
					print TODO ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{$key1}->{'description'} . "\n";
				} else {
					print TODO $key . " " . ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{$key1}->{'description'} . "\n";
				}
			} elsif ($doc->{lists}->{list}->{$key}->{action}->{$key1}->{'resolution'} eq "RESOLVED") {
				$rtimeaux = $doc->{lists}->{list}->{$key}->{action}->{$key1}->{'resolved'}; 
				$rtime = substr($rtimeaux,0,10);
				($Second, $Minute, $Hour, $DayAux, $MonthAux, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime($rtime);	
				$Year += 1900;
				$MonthAux++;

				$Day = substr(($DayAux + 100),1,2);
				$Month = substr(($MonthAux + 100),1,2);

				if ($key eq "In-Bucket") {
					print DONE "x $Year-$Month-$Day " . ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{$key1}->{'description'} . "\n";
				} else {
					print DONE "x $Year-$Month-$Day " . $key . " " . ($proj ? "p:$projs{$proj} " : ($queued eq "true" ? "p:NextActions " : "")) . $doc->{lists}->{list}->{$key}->{action}->{$key1}->{'description'} . "\n"; 
				}
			}
		}	
	}
}

close(TODO);
close(DONE);
