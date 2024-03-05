# cert-create

Perl-based OpenSSL command generator for generating ssl certificates.

Instructions:

1. Make `create.pl` executable.
```
$ chmod +x create.pl
```
2. Run the command with your info.
3. Run the outputted commands sequentially as needed.


Usage:

```
  Command        Domain       CAFilename     Company        City          State
  ./create.pl
  ./create.pl    myapp.com
  ./create.pl    myapp.com    ./localhost    "Web Media"    "New York"    "New York"

  ./create.pl    (help|man|--help|-h)
  ./create.pl    (--version|-v)
```
