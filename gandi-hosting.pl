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
use Data::Dumper;

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
            object_parse($vm_list, ['disks_id', 'ifaces_id']);
        }
    }
}

sub object_parse {
    my ( $object, $array ) = @_;
    my %name_list = ( disks_id => 'Disks lists: ', ifaces_id => 'Iface lists: ' );

    while ( my( $key, $value ) = each(%$object)) {
         foreach my $list (@$array) {
            if ( $key =~ m/$list/ ) {
                my $name = $name_list{$list};
                foreach my $a (@{$object->{$key}}) {
                    print "$name $a, ", "\n";
                }
            }
            else {
                next;
            }
         }
         if ( ! $value ) {
            $value = 'None';
         }
         print "$key: $value", "\n";
    }
}
