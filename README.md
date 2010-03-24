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
* Nicer List printing possible


Usage
------

    use lib "path/to/module";
    use DebugMessages errors => x, warnings => y, level => z, exit_on_warning => b, verbose => v;

with:

* b - 1 to exit the program when a warning occures.
* v - 1 to print compact Dumpvalues of Lists and Hashes. 2 to print verbose Dumpvalues.
* x - number of lines to print before and after the line that produced the error. -1 disables DebugMessages for errors.
* y - number of lines to print before and after the line that produced the warning. -1 disables DebugMessages for warnings.
* z - depth for stacktrace (default is 3)


List Output
-----------

Print your list @list = ("Hello World","How are you") with

    print "[@list]\n";

then you get 
    [Hello World] [How are you]

instead of
    [Hello World How are you]
