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
            object_parse($vm_list);
        }
    }
}

sub object_parse {
    my ( $object ) = @_;
    my %name_list = (
        shares        => 'Shares',
        date_created  => 'Date created',
        hostname      => 'Hostname',
        state         => 'State',
        vm_max_memory => 'Vm Max memory',
        id            => 'Id',
        datacenter_id => 'Datacenter',
        date_updated  => 'Date updated',
        cores         => 'Cores',
        memory        => 'Memory',
        disks_id      => 'Disks lists:', 
        ifaces_id     => 'Iface lists:' 
    );

    while ( my( $key, $value ) = each(%$object)) {
        my $name = $name_list{$key};

        if ( ref($value) eq 'ARRAY' ) {
            foreach my $id (@{$object->{$key}}) {
                print "$name $id, ", "\n";
            }
        }
        else {
            if ( ! $value ) {
                $value = 'None';
            }
            else {
                print "$name: $value", "\n";
            }
        }
    }
}
