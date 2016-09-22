#!/usr/bin/perl -w
#
# By Olivier BEDOUET - 09/2016
# Version 1.0

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../";

use VMware::VIRuntime;

$Util::script_version = "1.0";

sub create_folder;
sub delete_folder;
sub validate;

# Bug 222613
my %operations = (
   "create", "",
   "delete", "" ,
);

my %opts = (
   'operation' => {
      type => "=s",
      help => "Operation to be performed: create, delete",
      required => 1,
   },
   'folder' => {
      type => "=s",
      help => "Name of the virtual machine",
      required => 1,
   },
   'datacenter' => {
      type => "=s",
      help => "Name of the datacenter",
      required => 0,
   },
   'pool' => {
      type => "=s",
      help => "Name of the resource pool",
      required => 0,
   },
   'hostname' => {
      type => "=s",
      help => "Name of the host",
      required => 0,
   },
   'cluster' => {
      type => "=s",
      help => "Name of the cluster",
      required => 0,
   },
);


Opts::add_options(%opts);
Opts::parse();
Opts::validate(\&validate);

my $op = Opts::get_option('operation');
Util::connect();

if ($op eq "create") {
   create_folder();
} elsif ($op eq "delete") {
   delete_folder();
}

Util::disconnect();

# Handles the creation of the folder
sub create_folder() {

   my $hostname = Opts::get_option('hostname');
   #my $resourcepool = Opts::get_option('pool');
   my $folder = Opts::get_option('folder');
   my $datacenter = Opts::get_option('datacenter');
   #my $cluster = Opts::get_option('cluster');
   my $cluster_view;
   my $pool_views;

   #my $host_view = Vim::find_entity_view(view_type => 'HostSystem',
   #                                   filter => { 'name' => $hostname});
   #if(!$host_view) {
   #   Util::trace(0,"\nNo host found with name $hostname.\n");
   #   return;
   #}

   my $begin = Vim::find_entity_view (view_type => 'Datacenter',
                                         filter => {name => $datacenter});
   if (!$begin) {
      Util::trace(0, "\nNo data center found with name: $datacenter\n");
      return;
   }

   my $vmFolder_ref = $begin -> vmFolder;
   my $rf=Vim::get_view(mo_ref => $vmFolder_ref);
   $rf->CreateFolder(name => $folder);
   
}

# Handles the creation of the folder
sub delete_folder() {

   my $hostname = Opts::get_option('hostname');
   #my $resourcepool = Opts::get_option('pool');
   my $folder = Opts::get_option('folder');
   my $datacenter = Opts::get_option('datacenter');
   #my $cluster = Opts::get_option('cluster');
   my $cluster_view;
   my $pool_views;

   #my $host_view = Vim::find_entity_view(view_type => 'HostSystem',
   #                                   filter => { 'name' => $hostname});
   #if(!$host_view) {
   #   Util::trace(0,"\nNo host found with name $hostname.\n");
   #   return;
   #}

   my $begin = Vim::find_entity_view (view_type => 'Datacenter',
                                         filter => {name => $datacenter});
   if (!$begin) {
      Util::trace(0, "\nNo data center found with name: $datacenter\n");
      return;
   }

   my $vmFolder_ref = $begin -> vmFolder;
   my $folder_view=Vim::find_entity_view(view_type => 'Folder',
				filter => {name => $folder});
   if (!$folder_view) {
      Util::trace(0, "\nNo folder found with name: $folder\n");
      return;
   }

   print "WARNING: will recursively delete all VM registered under this folder. Do you still confirm (y/n) ?";
   my $input = scalar(<STDIN>);
   chop($input);
   if ($input =~ /\s*y\s*/i) {
       $folder_view->UnregisterAndDestroy_Task();
       return;
   }

   print "Delete abort";
}

sub validate {
   my $valid = 1;
   # bug 222613
   my $operation = Opts::get_option('operation');
   if ($operation) {
         if (!exists($operations{$operation})) {
         Util::trace(0, "Invalid operation: '$operation'\n");
         Util::trace(0, " List of valid operations:\n");
         map {print "  $_\n"; } sort keys %operations;
         $valid = 0;
      }
      if (($operation eq 'create')) {
         if (!Opts::option_is_set('folder')) {
            Util::trace(0, "\nMust specify parameter folder"
                         . " for create operation\n");
            $valid = 0;
         }
         if (!Opts::option_is_set('datacenter')) {
            Util::trace(0, "\nMust specify parameter datacenter"
                         . " for create operation\n");
            $valid = 0;
         }
      }
   }
   return $valid;
}

__END__

=head1 NAME

vmfolder.pl - Create or delete a folder into Vsphere Infrastructure

=head1 SYNOPSIS

 vmfolder.pl  --operation <create/delete> [options]

=head1 DESCRIPTION

This VI Perl command-line utility allows users to create or delete
folder into vSphere Infrastructure

=head1 OPTIONS

=head2 GENERAL OPTIONS

=over

=item B<operation>

Required. Operation to be performed. Must be one of the following:

  <create>
  <delete>

=back

=head2 CREATE OPTIONS

=over

=item B<folder>

Required. Name of the folder to create

=item B<datacenter>

Required. Name of the datacenter.

=back

=head2 DELETE OPTIONS

=over

=item B<folder>

Required. Name of the folder to delete.

=back

=head1 EXAMPLES

Create a folder

 vmfolder.pl  --url https://<ipaddress>:<port>/sdk/webService --username administrator
                --password mypassword --operation register --folder DEV

=head1 SUPPORTED PLATFORMS

All operations work with VMware VirtualCenter 2.0 or later.

All operations work with VMware ESX Server 3.0 or later.

