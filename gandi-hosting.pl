#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  gandi-hosting.pl
#
#        USAGE:  ./gandi-hosting.pl 
#
#  DESCRIPTION:  A CLI utility to manage your Gandi hosting resources.
#
#      OPTIONS:  vmlist
# REQUIREMENTS:  Config::IniFiles, File::HomeDir
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (Natal Ngétal), <hobbestig@cpan.org>
#      VERSION:  0.1
#      CREATED:  14/12/2010 13:26:03 CET
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Net::Gandi;
use Getopt::Long;
use Switch;
use Config::IniFiles;
use File::HomeDir qw(home);

#Config 
my $file = home() . "/.gandi-hostingsrc";
if ( ! -e $file ) {
    die "You must have a config file ~/.gandi-hostingsrc", "\n";
}
my $cfg     = Config::IniFiles->new( -file => $file );
my $api_key = $cfg->val('gandi', 'api_key');

#Get arguments
my %opts;
GetOptions ( \%opts, "vmlist");

#Dispatch to good function
switch (%opts) {
    case ('vmlist')  { vm_list() }
}

=head1 vm_list 

To list all vm.

=cut

sub vm_list {
    my $vm       = Net::Gandi::Hosting::VM->new(apikey => $api_key);
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

=head1 object_parse

Parse object returned, and format for printing

=cut

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
