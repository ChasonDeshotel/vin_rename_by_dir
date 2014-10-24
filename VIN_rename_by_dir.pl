#!/usr/bin/env perl
use strict;
use warnings;
use feature ':5.14';
use File::Spec;
use File::Copy;

my $root_dir = '/Users/cdeshotel/Dealermade/q_auto/photos';
my $new_dir = File::Spec->catdir( $root_dir, 'new_photos' );

opendir( DIR, $root_dir ) || die "[ERROR] can not open directory $root_dir";

my @files =
	grep { ! /^\./ } # no dot files
	grep { -d "$root_dir/$_" } # directories only
	readdir DIR
;
closedir(DIR);

# this is if you only want to rename certain directories
#my @vehicles = ('1HGCP2F3XBA087507','3FAHP0JA3BR230582','1C4NJPCBXCD568892','1G4PS5SK3C4180992','4T1BF1FK0CU540561','2G1FG1ED0B9189385','1N4AL3AP8DN460174','5XXGR4A62CG013771','1C6RD6NT5CS160344','1FTFW1ET7BKD58124','3GTP2XE23BG346392','3FADP4EJXBM232181','2A4GP54L07R280234','2B3KA43R18H168617','2T1BU4EE7DC978399');

foreach my $vehc ( @files ) {
#	if ( $vehc ~~ @vehicles ) {
#		say "found vehicle: $vehc";
#	};
	my $vehc_dir = File::Spec->catdir( $root_dir, $vehc );
	say "vehicle dir: $vehc_dir";

	# closeup images
	my $closeup_dir = File::Spec->catdir( $vehc_dir, 'closeup' );
	opendir( DIR, $closeup_dir ) || die "[ERROR] can not open directory $closeup_dir";
	my @closeup_files =
		grep { ! /^\./ } # no dot files
		grep { -f "$closeup_dir/$_" } # directories only
		readdir DIR
	;
	closedir( DIR );
	
	foreach my $file ( @closeup_files ) {
		my $abs_old_file = File::Spec->catfile( $closeup_dir, $file );
		$file =~ s/[A-Z0-9]{17}(-\d\d\d.jpg)/$vehc$1/;
		my $abs_new_file = File::Spec->catfile( $new_dir, $file );
		
		say "copying $abs_old_file -> $abs_new_file";
		copy( $abs_old_file , $abs_new_file )
			|| die "[ERROR] could not move file $!";
		
	}

	# exterior images
	my $ext_dir = File::Spec->catdir( $vehc_dir, 'ext' );
	opendir( DIR, $ext_dir ) || die "[ERROR] can not open directory $ext_dir";
	my @ext_files =
		grep { ! /^\./ } # no dot files
		grep { -f "$ext_dir/$_" } # directories only
		readdir DIR
	;
	closedir( DIR );
	
	foreach my $file ( @ext_files ) {
		my $abs_old_file = File::Spec->catfile( $ext_dir, $file );
		#say "old: $file";
		$file =~ s/ext-[A-Z0-9]{17}(-\d\d\d.jpg)/ext-$vehc$1/;
		#say "new: $file";
		my $abs_new_file = File::Spec->catfile( $new_dir, $file );
		
		say "copying $abs_old_file -> $abs_new_file";
		copy( $abs_old_file , $abs_new_file )
			|| die "[ERROR] could not move file $!";
	}

}

=head1 NAME

VIN_rename_by_dir.pl - The almighty VIN picture renamer

=head1 AUTHOR

Chason Deshotel, me@chasondeshotel.com

=head1 SYNOPSIS

turns something like

	/root_dir/VIN/ext/DCIM-1.jpg
	/root_dir/VIN/closeup/DCIM-10.jpg

into

	/root_dir/to_upload/ext-VIN-1.jpg
	/root_dir/to_upload/VIN-1.jpg

which is a format accepted by a certain server for vehicle
image uploads

all new images get pushed to a new directory so that
we can upload everything with a simple ncftpput one liner
