#!/usr/bin/env perl
use strict;
use warnings;

my $v = "0.0.2";
my $man = '
Copyright (C) 2024 Ray (github.com/ryt)

OpenSSL command generator for generating ssl certificates.

Usage:
  Command        Domain       CAFilename     Company        City          State
  ./create.pl
  ./create.pl    myapp.com
  ./create.pl    myapp.com    ./localhost    "Web Media"    "New York"    "New York"

  ./create.pl    (help|man|--help|-h)
  ./create.pl    (--version|-v)

';

my ($filename, $cafilename, $company, $city, $state) = @ARGV;

if ( not defined $filename ) {
  $filename = 'localhost';
}

if ( not defined $cafilename ) {
  $cafilename = $filename;
} else {
  $cafilename =~ s/-CA\.(crt|key)//gi;
}

if ( not defined $company ) {
  $company = 'Web App Local';
}

if ( not defined $city ) {
  $city = 'Los Angeles';
}

if ( not defined $state ) {
  $state = 'California';
}

my $ctry = 'US';
my $main = '';

# for firefox (https://stackoverflow.com/a/77009337)

# step 1 (first command to run)
my $main1 = 
  "openssl req -x509 -nodes " . 
  "-newkey RSA:2048 " . 
  "-keyout $filename-CA.key " . 
  "-days 365 " . 
  "-out $filename-CA.crt " . 
  "-subj '/C=$ctry/ST=$state/L=$city/O=$company/CN=${filename}_CA_Firefox'";

# step 2 (second command)
my $main2 = 
  "openssl req -nodes " . 
  "-newkey rsa:2048 " . 
  "-keyout $filename.key " . 
  "-out $filename.csr " . 
  "-subj '/C=$ctry/ST=$state/L=$city/O=$company/emailAddress=contact\@$filename/CN=${filename}'";

# step 3 (third command)
my $main3 = 
  "openssl x509 -req " . 
  "-CA $cafilename-CA.crt " . 
  "-CAkey $cafilename-CA.key " . 
  "-in $filename.csr " . 
  "-out $filename.crt " . 
  "-days 365 " . 
  "-CAcreateserial " . 
  "-extfile " . 
    '<(printf "' . 
      'subjectAltName = DNS:' . $filename . '\n' . 
      'authorityKeyIdentifier = keyid,issuer\n' . 
      'basicConstraints = CA:FALSE\n' . 
      'keyUsage = digitalSignature, keyEncipherment\n' . 
      'extendedKeyUsage=serverAuth")';

if ( $cafilename eq $filename ) {

  # Since an existing (different) CA file hasn't been specified, create new CA along with certificates in three steps:

  $main = 
    "<Using: $filename, $cafilename, $company, $city, $state>\n\n" . 
    "---- Three separate steps of commands for Firefox: ---- \n\n" . 
    $main1 . "\n\n" . $main2 . "\n\n" . $main3 . "\n\n" . 
    "---- Run all the commands sequentially below: ---- \n\n" . 
    $main1 . " && " . $main2 . " && " . $main3;

} else {

  # Using existing CA (Certificate Authority) file will only require two steps.

  $main = 
    "<Using: $filename, $cafilename, $company, $city, $state>\n\n" . 
    "---- Two steps of commands with existing CA file for Firefox: ---- \n\n" . 
    $main2 . "\n\n" . $main3 . "\n\n" . 
    "---- Run all the commands sequentially below: ---- \n\n" . 
    $main2 . " && " . $main3;

}

# end for firefox


# main all-in-one
=pod
my $main = 
  "openssl req -x509 " . 
  "-out $filename.crt " . 
  "-keyout $filename.key " . 
  "-newkey rsa:2048 " . 
  "-nodes -sha256 " .
  "-days 365 " .  
  "-subj '/CN=$filename/O=$company/L=$city/ST=$state/C=$ctry/emailAddress=contact\@$filename' " . 
  "-extensions EXT -config <( " . 
    ' printf "[dn]\n' . 
            'CN=' . $filename . '\n[req]\n' . 
            'distinguished_name=dn\n[EXT]\n' . 
            'subjectAltName=DNS:'.$filename.'\n' . 
            'basicConstraints=critical,CA:TRUE\n' . 
            'keyUsage=digitalSignature\n' . 
            'extendedKeyUsage=serverAuth")';
=cut
# end main all-in-one

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

my $command = $filename;

if ( $command eq '' ) {
  print "Use 'help' or 'man' for proper usage.\n";
} elsif ( $command eq 'help' or $command eq '--help' or $command eq '-h' or $command eq 'man' ) {
  print trim($man) . "\n\n";
} elsif ( $command eq 'version' or $command eq '--version' or $command eq '-v' ) {
  print "Version $v\n";
} else {
  print("\n" . $main . "\n\n");
}

