#! /usr/bin/perl
use warnings;
use Term::ANSIColor qw(:constants);

my @list;
my @done;
my @failed;
my @editors;
my $failure;
my $file;
my $filename;

sub getfile;

@editors = (q{nano},q{vim},q{vi});
$file = "/tmp/dlmanagerList";

foreach(@editors)
{
    if (system(qq{$_ $file 2>/dev/null}) == 0)
    {
	last;
    }
}

open(FILE, "<", $file) or die "Could not open $file: $!\n";
@list = <FILE>;
close(FILE);

foreach( @list )
{
    $failure = 0;
    
    $_ =~ s/^http:/https:/;
    
    if( getfile( $_ ) == 1 ){
        print RED, qq{FAILED, trying unsecure mode (http)...\n}, RESET;
        $_ =~ s/^https/http/;
        $failure = 1;
    }
    
    if( $failure == 1 )
    {
	if( getfile( $_ ) == 1 )
	{
	    print RED, qq{FAILED\n}, RESET;
	    push @failed, $filename;
	}
    }
    
}

print "\n\nTelechargements effectues:\n###----------------------###\n";
foreach( @done )
{
    print $_,qq{\n};
}
print "###------------------------------------------------------------------###\n\n";
print "Telechargements echoues:\n###----------------------###\n";
foreach( @failed )
{
    print $_,qq{\n};
}
print "###------------------------------------------------------------------###\n\n";
unlink( "$file" );

sub getfile
{
    ( $line ) = @_;
    $line =~ s/\n//g;
    $line =~ s/\s+$//g;
    if( !$line )
    {
	return 0;
    }
    ( $filename ) = $line =~ m|([^/]+)/?$|;
    $filename =~ s/%20/ /g;
    $filename =~ s/%5B/[/g;
    $filename =~ s/%5D/]/g;
    print qq{Getting $filename:};
    
    if (system("wget -c -q --no-check-certificate $line") == 0)
    {
	print GREEN, qq{OK\n}, RESET;
	push @done, $filename;
	return 0;
    }
    else
    {
	return 1;
    }
}
__END__
