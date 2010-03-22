DebugMessages for perl
======================

Include this module in your perl projects for getting a stacktrace in case of an error or warning.



Features
---------

* Prints out stacktrace with given depth
* Prints out error messages and warnings
* Prints out x lines before and after error
* Prints out all parameters of called functions
* Automatic indenting


Usage
------

    use lib "path/to/module";
    use DebugMessages fatal => x, warnings => y, level => z, exit_on_warning => b;

with:

* b - 1 to exit the program when a warning occures.
* x - number of lines to print before and after the line that produced the error
* y - number of lines to print before and after the line that produced the warning
* z - depth for stacktrace (default is 3)
