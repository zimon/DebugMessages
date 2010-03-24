#
# Package: DebugMessages
#
# Overwrites warn and die function to print a verbose stacktrace
#
# Usage:
# Import this file with
# use lib "path/to/my/modules"
# use DebugMessages errors => x, warnings => y, level => z, exit_on_warning => b, verbose => v;
#
# where "path/to/my/modules" is replaced with the path to this file.
#
# You can use the following variables:
# b - 1 to exit the program when a warning occures.
# v - 1 to print compact Dumpvalues of Lists and Hashes. 2 to print verbose Dumpvalues.
# x - number of lines to print before and after the line that produced the error. -1 disables DebugMessages for errors.
# y - number of lines to print before and after the line that produced the warning. -1 disables DebugMessages for warnings.
# z - depth for stacktrace (default is 3).

package DebugMessages;

use strict;
use warnings;
use Dumpvalue;

##
# Field seperator for list-to-string conversation. 

# print out your lists with
#
#  print "[@myarray]\n";
$" = '] [';

##
# Is called when this package is used somewhere. Overwrites warn and die functions
sub import {
    my ( $class, %args ) = @_;
    my $level = $args{level};
    my $dump = $args{verbose};
    my $warningsize = $args{warnings};
    my $errorsize = $args{errors};
    $dump = 0 unless defined $args{verbose};
    my $exit_on_warning = $args{exit_on_warning};
    $level = 3 unless defined $level;
    $exit_on_warning = 0 unless defined $exit_on_warning;
    $warningsize = 3 unless defined $warningsize;
    $errorsize = 3 unless defined $errorsize;
    

    $SIG{__DIE__} = sub { DB::report( shift, $errorsize, $level, $dump ); exit; } if $args{errors} && $args{errors} >= 0;
    $SIG{__WARN__} = sub { DB::report( shift, $warningsize, $level, $dump); exit if $exit_on_warning; } if $args{warnings} && $args{warnings} >= 0;
}

package DB;

##
# Collects all informations for stacktrace. Calls <showSource> to get the lines and prints the stacktrace to STDERR.
#
# PARAMETERS:
# $message - errormessage that came from the program
# $size - number of lines to print before and after the error line
# $level - depth of the stacktrace
sub report {
    my ( $message, $size, $level ,$dump) = @_;
    $level ||= 1;
    my @callValueList    = ();
    my @callArgumentList = ();
    for ( my $i = 1 ; $i <= $level + 1 ; $i++ ) {
        my @callValues    = caller($i);
        my @callArguments = @DB::args;
        push( @callValueList,    \@callValues );
        push( @callArgumentList, \@callArguments );
    }
    my %calls = ( CALLVALUES => \@callValueList, CALLARGUMENTS => \@callArgumentList );

    showSource( $size, $dump, %calls );
}

##
# Get all needed lines from program files and genrate output
#
# PARAMETERS:
# $size - number of lines to print before and after error line
# @calls - array with references to caller returned arrays and function arguments
#
# RETURNS:
# string with stacktrace
sub showSource {
    my $size  = shift;
    my $dump = shift;
    my %calls = @_;

    my @text;
    my @callValueList    = @{ $calls{CALLVALUES} };
    my @callArgumentList = @{ $calls{CALLARGUMENTS} };
    my $dumper = new Dumpvalue;
    $dumper->compactDump(1) if $dump == 1;
    #$dumper->veryCompact(1);
    my $tab              = "";
    my $i                = 0;
    local $.;

    do {
        my ( $package, $fileName, $line, $subroutine ) = @{ $callValueList[$i] };
        my @arguments = @{ $callArgumentList[$i] };
        if ( defined $fileName ) {    # next is not possible in do-while loop
            my $fh;

            # Open source file or return all informations till now
            print STDERR "\n$subroutine(" . join( ",", @arguments ) . 
              ") at line $line in file $fileName (package $package):\nCan not print lines because opening file $fileName is not possible.\n\n" 
              and return unless open( $fh, $fileName );

            my $start = $line - $size;
            my $end   = $line + $size;
            if($dump and $i > 0){
                print STDERR "\n-------------------------------------\n";
                print STDERR "Verbose output of parameters for call of $subroutine\n";
                foreach my $arg (@arguments) {
                    $dumper->dumpValue($arg);
                }
                print STDERR "-------------------------------------\n";
            }

            print STDERR "\nError: " . join( ",", @arguments ) . "\n" if $i == 0;

            print STDERR "\n$tab $subroutine(" . join( ",", @arguments ) . ") called at line $line in file $fileName (package $package):\n" if $i > 0;

            while (<$fh>) {
                next unless $. >= $start;
                last if $. > $end;
                my $highlight = $. == $line ? '* ' : '  ';
                printf( "%s %s%04d: %s", $tab, $highlight, $., $_ );
            }
            $tab .= "  ";
        }
        $i++;
    } while ( $i < $#callValueList );
    print STDERR "\n\n";
}

1;
