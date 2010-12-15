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
use Config::IniFiles;
use File::HomeDir qw(home);
use Pod::Usage;

#GLOBAL
my $cfg;
my $api_key;

MAIN: {
    run() unless caller();
}

sub run {
    #Config 
    my $file = home() . "/.gandi-hostingrc";
    if ( ! -e $file ) {
        die "You must have a config file ~/.gandi-hostingrc", "\n";
    }
    $cfg     = Config::IniFiles->new( -file => $file );
    $api_key = $cfg->val('gandi', 'api_key');

    #Get arguments
    my %opts;
    GetOptions ( \%opts, 
        "vmlist", 
         "vminfo=i",
         "ifacelist",
         "help"
    ) or help(1);

    #Dispatch to good function
    vm_list()              if $opts{vmlist};
    vm_info($opts{vminfo}) if $opts{vminfo};
    iface_list()           if $opts{ifacelist};
    help(2)                if $opts{help};
}

sub help {
    my ( $level ) = @_;
    require Pod::Usage;
    pod2usage($level);
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

sub vm_info {
    my ( $vm_id ) = @_;
    my $vm        = Net::Gandi::Hosting::VM->new(apikey => $api_key, id => $vm_id);
    my $vm_info   = $vm->info();

    object_parse($vm_info) if $vm_info;
}

sub iface_list {
    my $iface       = Net::Gandi::Hosting::Iface->new(apikey => $api_key);
    my $iface_lists = $iface->list();

    if ( ! $iface_lists ) {
        print "You don't have iface";
        return;
    }
    else {
        foreach my $iface_list (@{$iface_lists}) {
            object_parse($iface_list);
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
        ifaces_id     => 'Iface lists:',
        graph_urls    => 'Url of the graph:',
        vif           => 'Url graph for vif:',
        vdi           => 'Url graph for vdi:',
        vcpu          => 'Url graph for vcpu:',
    );

    while ( my( $key, $value ) = each(%$object)) {
        my $name = $name_list{$key};

        if ( ref($value) eq 'ARRAY' ) {
            foreach my $id (@{$object->{$key}}) {
                print "$name $id, ", "\n";
            }
        }
        elsif ( ref($value) eq 'HASH' ) {
            object_parse($value);
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


__END__

=head1 NAME

gandi-hosting - A CLI utility to manage your Gandi hosting resources.

=head1 SYNOPSIS

    gandi-hosting <options>

    options:
      --vmlist                       print all vm 
      --vminfo=42 | --vminfo 42      print info of the vm
      --ifacelist                    print all ifaces
      --help                         print this message

=head1 OPTIONS

=over

=item B<--vmlist>

Print all vm 

=item B<--vminfo=42 | --vminfo 42>

Print information of the vm

=item B<--ifacelist>

Print all ifaces.

=item B<--help>

Print help message

=back 

=head1 DESCRIPTION

This program is a simple command-line interface to Net::Gandi.
Help to manage your Gandi hosting resources.

=cut

