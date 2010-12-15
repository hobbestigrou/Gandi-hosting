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
         "disklist",
         "diskinfo=i",
         "ifacelist",
         "ifaceinfo=i",
         "iplist",
         "ipinfo=i",
         "help"
    ) or help(1);

    #Dispatch to good function
    vm_list()                    if $opts{vmlist};
    vm_info($opts{vminfo})       if $opts{vminfo};
    disk_list()                  if $opts{disklist};
    disk_info($opts{diskinfo})   if $opts{diskinfo};
    iface_list()                 if $opts{ifacelist};
    iface_info($opts{ifaceinfo}) if $opts{ifaceinfo};
    ip_list()                    if $opts{iplist};
    ip_info($opts{ipinfo})       if $opts{ipinfo};
    help(2)                      if $opts{help};
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

sub disk_list {
    my $disk       = Net::Gandi::Hosting::Disk->new(apikey => $api_key);
    my $disk_lists = $disk->list();

    if ( ! $disk_lists ) {
        print "You don't have disk";
        return;
    }
    else {
        foreach my $disk_list (@{$disk_lists}) {
            object_parse($disk_list);
        }
    }
}

sub disk_info {
    my ( $disk_id ) = @_;
    my $disk        = Net::Gandi::Hosting::Disk->new(apikey => $api_key, id => $disk_id);
    my $disk_info   = $disk->info();

    object_parse($disk_info) if $disk_info;
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

sub iface_info {
    my ( $iface_id ) = @_;
    my $iface        = Net::Gandi::Hosting::Iface->new(
        apikey => $api_key, 
        id => $iface_id
    );
    my $iface_info   = $iface->info();

    object_parse($iface_info) if $iface_info;
}

sub ip_list {
    my $ip       = Net::Gandi::Hosting::IP->new(apikey => $api_key);
    my $ip_lists = $ip->list();

    if ( ! $ip_lists ) {
        print "You don't have ip";
        return;
    }
    else {
        foreach my $ip_list (@{$ip_lists}) {
            object_parse($ip_list);
        }
    }
}

sub ip_info {
    my ( $ip_id ) = @_;
    my $ip      = Net::Gandi::Hosting::IP->new(apikey => $api_key, id => $ip_id);
    my $ip_info = $ip->info();

    object_parse($ip_info) if $ip_info;
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
        my $name = $name_list{$key} || $key;

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
      --disklist                     print all disk
      --diskinfo=42 | --diskinfo 42  print info about disk
      --ifacelist                    print all ifaces
      --ifaceinfo=42 | ifaceinfo 42  print info of the iface
      --iplist                       print all ip
      --ipinfo                       print info about ip
      --help                         print this message

=head1 OPTIONS

=over

=item B<--vmlist>

Print all vm 

=item B<--vminfo=42 | --vminfo 42>

Print information of the vm

=item B<--disklist>

Print all disk

=item B<--diskinfo=42 | --diskinfo 42>

Print information about disk

=item B<--ifacelist>

Print all ifaces

=item B<--ifaceinfo=42 | --ifaceinfo 42>

Print information of the iface

=item B<--iplist>

Print all ip

=item B<--ipinfo=42 | --ipinfo 42>

Print inforamation about ip

=item B<--help>

Print help message

=back 

=head1 DESCRIPTION

This program is a simple command-line interface to Net::Gandi.
Help to manage your Gandi hosting resources.

=cut

