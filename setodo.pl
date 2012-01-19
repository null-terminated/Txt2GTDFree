#!/bin/perl
use XML::Element;
use Config::Properties;

open PROPS, "< config.properties"
	|| die "unable to open configuration file";
my $properties = new Config::Properties();
$properties->load(*PROPS);

my $fileGtdFree = $properties->getProperty('GTDFREEXML');
my $fileTodo = $properties->getProperty('TODOTXT');
my $fileDone = $properties->getProperty('DONETXT');

open(TODO,">$fileTodo")
	|| die("Nao foi possivel abrir arquivo Todo");
open(DONE,">$fileDone")
	|| die("Nao foi possivel abrir arquivo Done");

require "files/camelid_links.pl";
my %camelid_links = get_camelid_data();

my $root = XML::Element->new('html');
my $body = XML::Element->new('body');
my $xml_pi = XML::Element->new('~pi', text => 'xml version="1.0"');
$root->push_content($body);

foreach my $item ( keys (%camelid_links) ) {
    my $link = XML::Element->new('a', 'href' => $camelid_links{$item}->{url});
    $link->push_content($camelid_links{$item}->{description});
    $body->push_content($link);
}

print $xml_pi->as_XML;
print $root->as_XML();