#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  essai1000.pl
#
#        USAGE:  ./essai1000.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  12/12/2010 13:26:03 CET
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Net::Gandi;
use Getopt::Long;
use Switch;
use Config::IniFiles;
use File::HomeDir qw(home);

my $file = home() . "/.gandi-hostingsrc";

if ( ! -e $file ) {
    die "You must have a config file ~/.gandi-hostingsrc", "\n";
}

my $cfg  = Config::IniFiles->new( -file => $file );

my %opts;
GetOptions ( \%opts, "vmlist");

switch (%opts) {
    case ('vmlist')  { vm_list() }
}

sub vm_list {
    my $vm       = Net::Gandi::Hosting::VM->new(apikey => $cfg->val('gandi', 'api_key'));
    my $vm_lists = $vm->list();

    if ( ! $vm_lists ) {
        print "You don't have vm";
        return;
    }
    else {
        foreach my $vm_list (@{$vm_lists}) {
	    while (my ( $key, $value ) = each(%$vm_list)) {
	        if ( $key =~ m/name/ ) {
		    print "Information about $value ";
	        }
                if ( $key =~ m/disks_id/ || $key =~ m/ifaces_id/ ) {
		    my $name = "Disks lists: ";
		    if ( $key  =~ m/ifaces_id/ ) {
		        $name = "Ifaces lists: ";
		    }
		    foreach my $array (@{$vm_list->{$key}}) {
		        print "$name $array, ", "\n";
		    }
	        }
	       else {
	           if ( ! $value ) {
		       $value = 'None';
		   }
		   print "$key: $value", "\n";
	       } 
	    }
        }
    }
}
