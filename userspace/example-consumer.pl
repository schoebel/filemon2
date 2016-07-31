#!/usr/bin/perl -w
#
# example consumer / demo for filemon2
#
# Copyright (C) 2016 Thomas Schoebel-Theuer
# Copyright (C) 2016 1&1 Internet AG
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use English;
use warnings;

umask 0077;

##################################################################

# This demo code is not intended for production use.

# The granularity of logfile processing is whole logfiles only.
# When the last logfile is incomplete (which is often the case),
# this logfile is re-read upon the next call of $0.
# More sophisticated granularity is also possible, but not the scope
# of this demo.

my $res = shift || die "no resource argument given";
die "resource '$res' has no .filemon2 subdirectory" unless -d "$res/.filemon2/";

my $appname = shift || "example1";

my $start_logfile;
my $start_position = `grep -v '^#' "$res/.filemon2/position-$appname.status"`;
if ($start_position) {
  $start_logfile = sprintf("%s/.filemon2/eventlog-%09d.log", $res, $start_position);
} else {
  my @logfiles = sort(glob("$res/.filemon2/eventlog-*.log"));
  $start_logfile = shift @logfiles;
}

sub __conv_tv {
  my ($tv_sec, $tv_nsec) = @_;
  if (defined($tv_nsec)) {
    $tv_nsec = ".$tv_nsec";
  } else {
    $tv_nsec = "";
  }
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(int($tv_sec));
  return "$tv_sec$tv_nsec" unless defined($sec);
  return sprintf("%04d-%02d-%02d %02d:%02d:%02d%s", $year+1900, $mon + 1, $mday, $hour, $min, $sec, $tv_nsec);
}

sub update_position {
  my ($res, $lognr) = @_;;
  open OUT, "> $res/.filemon2/position-$appname.status.tmp" or die "cannot create position file";
  print OUT "$lognr\n" or die "cannot write position";
  close OUT;
  rename("$res/.filemon2/position-$appname.status.tmp", "$res/.filemon2/position-$appname.status");
}

sub hook_global_in_here {
  my ($type, $epoch_stamp, $log_stamp) = @_;
  # Do something with ($type, $epoch_stamp, $log_stamp) here....
}

sub hook_variable_in_here {
  my ($var, $value) = @_;
  # Do something with $var and $value here....
}

my @field_names;

sub csv_header {
  my $line = shift;
  chomp $line;
  @field_names = split(/ /, $line);
}

sub hook_csv_in_here {
  my $line = shift;
  chomp $line;
  my %record;
  my @copy = @field_names;
  foreach my $value (split(/ /, $line)) {
    my $field = shift @copy;
    $record{$field} = $value;
  }
  # Do something with %record here....
}

# parse a logfile and create some statistics
sub read_logfile {
  my ($res, $filename) = @_;
  $filename =~ m:/eventlog-([0-9]+): or die "cannot parse logfile '$filename'";
  my $lognr = $1;
  $lognr =~ s/^0*//;
  open IN, "< $filename" or die "cannot open logfile '$filename'";
  my $line_nr = 0;
  my $global_nr = 0;
  my $variable_nr = 0;
  my $csv_nr = 0;
  my $is_complete;
  my $epoch = 0;
  while (my $line = <IN>) {
    $is_complete = 0;
    $line_nr++;
    # skip the CSV header
    if ($line_nr == 1) {
      csv_header($line);
    } elsif ($line =~ m/^## (\w+)=(.*)/) {
      my $var = $1;
      my $value = $2;
      $global_nr++;
      hook_variable_in_here($var, $value);
    } elsif ($line =~ m/^# (\w+) *([0-9.]+) ([0-9.]+)/) {
      my $type = $1;
      $epoch = $2;
      my $now = $3;
      $variable_nr++;
      $is_complete++ if ($type eq "LOGROT_BEGIN" || $type eq "UMOUNT");
      hook_global_in_here($type, $epoch, $now);
    } else {
      $csv_nr++;
      hook_csv_in_here($line);
    }
  }
  close IN;

  print "$filename\t$is_complete\t$epoch ("
    . __conv_tv($epoch)
    . ")\t$global_nr\t$variable_nr\t$csv_nr\n";

  update_position($res, $lognr);
  return $lognr;
}

my $logfile = $start_logfile;
while (-r $logfile) {
  my $lognr = read_logfile($res, $logfile);
  $lognr = sprintf("%09d", $lognr + 1);
  $logfile =~ s:/eventlog-[0-9]+:/eventlog-$lognr:;
}
