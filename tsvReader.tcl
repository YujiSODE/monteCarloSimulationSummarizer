#monteCarloSimulationSummarizer
#tsvReader.tcl
##===================================================================
#	Copyright (c) 2023 Yuji SODE <yuji.sode@gmail.com>
#
#	This software is released under the MIT License.
#	See LICENSE or http://opensource.org/licenses/mit-license.php
##===================================================================
#It read a filepath for TSV file or SSV file and load the its first two columnar contents as xy data, where TSV and SSV stand for Tab-separated values and Space-separated values.
#The returned value is $keyName.
#
#=== Synopsis ===
#`tsvReader filepath ?keyName?`
#
#- $filepath: filepath for TSV file or SSV file
#- $keyName: a word for function names that will be added
#
#<namespace ::tcl::mathfunc>
#list of functions that will be added
# - `${keyName}_X(index)`: it returns a file value of x with an index
# - `${keyName}_Y(index)`: it returns a file value of y with an index
# - `${keyName}_Nx()`: it returns the number of x data elements
# - `${keyName}_Ny()`: it returns the number of y data elements
##===================================================================
#
proc tsvReader {filepath {keyName {}}} {
	#- $filepath: filepath for TSV file or SSV file
	#- $keyName: a word for function names that will be added
	#
	#<namespace ::tcl::mathfunc>
	#list of functions that will be added
	# - `${keyName}_X(index)`: it returns a file value of x with an index
	# - `${keyName}_Y(index)`: it returns a file value of y with an index
	# - `${keyName}_Nx()`: it returns the number of x data elements
	# - `${keyName}_Ny()`: it returns the number of y data elements
	#--------------------------------------------------------------------
	#
	set keyName [expr {![llength $keyName]?[clock seconds]:$keyName}];
	set keyName [expr {[llength $keyName]>1?[join $keyName _]:$keyName}];
	set keyName [regsub -all {[^_\-+0-9a-zA-Z]} $keyName {_}];
	#
	set eList {};
	#
	set X {};
	set Y {};
	set Nx 0;
	set Ny 0;
	#
	set C [open $filepath r];
	set V [read -nonewline $C];
	close $C;
	#
	foreach e [split $V \n] {
		#
		#to convert double space characters into a single space character
		set e [regsub -all {\u0020\u0020+} $e \u0020];
		set e [regsub -all {\t\t+} $e \t];
		#
		#to remove white space characters at the beginning of string
		set e [regsub {^[\s]+} $e {}];
		#
		set eList [split $e];
		#
		#a horizontal row is regarded as a comment if it includes word "#"
		if {{#} ni [split $e {}]&&[llength $eList]>1} { 
			lappend X [lindex $eList 0];
			lappend Y [lindex $eList 1];
		};
	};
	#
	set Nx [llength $X];
	set Ny [llength $Y];
	#
	#addition of functions to namespace ::tcl::mathfunc
	#
	#`${keyName}_Y(index)`: it returns a file value of x with an index
	#index = 0, 1, 2, ..., N-1
	set f [subst {proc ::tcl::mathfunc::${keyName}_X index \{return \[lindex [list $X] \[expr \{int\(\$index\)\}\]\];\};}];
	eval $f;
	#
	#`${keyName}_Y(index)`: it returns a file value of y with an index
	#index = 0, 1, 2, ..., N-1
	set f [subst {proc ::tcl::mathfunc::${keyName}_Y index \{return \[lindex [list $Y] \[expr \{int\(\$index\)\}\]\];\};}];
	eval $f;
	#
	#`${keyName}_Nx()`: it returns the number of x data elements
	set f [subst {proc ::tcl::mathfunc::${keyName}_Nx {} \{return \[expr \{int\($Nx\)\}\];\};}];
	eval $f;
	#
	#`${keyName}_Ny()`: it returns the number of y data elements
	set f [subst {proc ::tcl::mathfunc::${keyName}_Ny {} \{return \[expr \{int\($Ny\)\}\];\};}];
	eval $f;
	#
	#Log
	puts stdout "\#--- tsvReader ---\nsource: $filepath";
	puts stdout "\#namespace ::tcl::mathfunc";
	puts stdout "\#X values: `${keyName}_X(index)`";
		#puts stdout "X: $X";
	puts stdout "\#Y values: `${keyName}_Y(index)`";
		#puts stdout "Y: $Y";
	puts stdout "\#number of x data elements: `${keyName}_Nx(index)`";
		#puts stdout "Nx: $Nx";
	puts stdout "\#number of Y data elements: `${keyName}_Ny(index)`";
		#puts stdout "Ny: $Ny";
	puts stdout "keyName: $keyName\n\#-------";
	#--------------------------------------------------------------------
	#
	unset eList X Y Nx Ny C V;
	#
	return $keyName;
};
#
