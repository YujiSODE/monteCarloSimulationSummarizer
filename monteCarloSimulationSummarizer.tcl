#monteCarloSimulationSummarizer
#monteCarloSimulationSummarizer.tcl
##===================================================================
#	Copyright (c) 2023 Yuji SODE <yuji.sode@gmail.com>
#
#	This software is released under the MIT License.
#	See LICENSE or http://opensource.org/licenses/mit-license.php
##===================================================================
#The Monte Carlo Simulation Summarizer (MCSS) is a tool to summarize results of random simulation.
#
#=== Synopsis ===
#`::MCSS::INPUT list`
#`::MCSS::OUTPUT outputName`
#
#command `INPUT` inputs a single result of random simulation, and returns input list size
#command `OUTPUT` returns a keyword named after `$outputName` and generates a new directory, where to output three results and some additional sources
#
#	**three main results to output**  
#	- `${outputName}_MCSS[numbers]_LOG.md`: log in Markdown file
#	- `${outputName}_MCSS[numbers]_INFO.csv`: summarized information in CSV file
#	- `${outputName}_MCSS[numbers]_DATA.csv`: frequency distribution in CSV file
#
#--------------------------------------------------------------------
#=== Description ===
#*** <namespace ::MCSS> ***
#**procedures**
# - `::MCSS::getFreq list`: it returns frequencies based on a given list
#___
# - `::MCSS::SET_RANGE x1 x2`: it sets the range of random value and returns the current value
# - `::MCSS::RANDOM`: it returns a pseudo-random floating-point value in a range [x1,x2], which is defined by `$::MCSS::RANGE`
# - `::MCSS::SET_FORMAT ?formatString?`: it sets the format string and returns the current value
#___
# - `::MCSS::ADD_NOTE name value`: it adds a note and returns a added values in a list (`{$name $value}`)
# - `::MCSS::INCLUDE path`: it adds a file path to be included in output and returns added path
# - `::MCSS::reset`: it resets variables in namespace `::MCSS`
#___
# - `::MCSS::getMetadata`: it returns metadata as a text in Markdown
# - `::MCSS::getDist`: it returns frequency distribution as a list (`{{name mean std} ...}`)
# - `::MCSS::getInfo`: it returns summarized information as a list (`{{name mean std} ...}`)
#___
# - `::MCSS::INPUT list`: it is interface to input a single result of random simulation, and returns input list size
# - `::MCSS::OUTPUT outputName`: it returns a keyword named after `$outputName` and generates a new directory, where to output three results and some additional sources
#
#**arguments**
# - `$list`: a numerical list
# - `$formatString`: an optional format string, `%.4f` is default
# - `$x1` and `$x2`: a numerical values
# - `$name`: name of an input value
# - `$value`: value of an input value 
# - `$path`: a file path
# - `$outputName`: a name for a keyword of the new directory to output
#
#** variable **
# - `$::MCSS::EPSILON`: estimated machine epsilon
#
#--------------------------------------------------------------------
#*** <namespace ::tcl::mathfunc> ***
#additional math functions
#--- lSum.tcl (Yuji SODE, 2018): https://gist.github.com/YujiSODE/1f9a4e2729212691972b196a76ba9bd0 ---
# - `lSum(list)`: function that returns sum of given list
#   - `$list`: a numerical list
#
#--------------------------------------------------------------------
# - `avg(list)`: function that estimates average using a given numerical list
#   - `$list`: a numerical list
#
# - `var(list,?m?)`: function that estimates variance using a numerical list (and an optional mean) with "list size -1"
#   - `$list`: a numerical list
#   - `$m`: an optional mean value
#
##===================================================================
set auto_noexec 1;
package require Tcl 8.6;
# ===============
#
#additional math functions
#*** <namespace ::tcl::mathfunc> ***
namespace eval ::tcl::mathfunc {
	#=== lSum.tcl (Yuji SODE, 2018): https://gist.github.com/YujiSODE/1f9a4e2729212691972b196a76ba9bd0 ===
	#it returns sum of given list
	#Reference: Iri, M. and Fujino, Y. 1985. Suchi keisan no joshiki (Japanese). Kyoritsu Shuppan Co., Ltd. ISBN 978-4-320-01343-8
	proc lSum {list} {namespace path {::tcl::mathop};set S 0.0;set R 0.0;set T 0.0;foreach e $list {set R [+ $R [expr double($e)]];set T $S;set S [+ $S $R];set T [+ $S [expr {-$T}]];set R [+ $R [expr {-$T}]];};return $S;};
	#
	#it estimates average using a given numerical list
	proc avg {list} {
		# - $list: a numerical list
		set v {};
		#n is list size
		set n [expr {double([llength $list])}];
		#
		#means
		set m 0.0;
			######
			set _m [lindex $list [expr {int($n*0.5)}]];
			######
		#
		foreach e $list {
			lappend v [expr {double($e)-double($_m)}];
		};
		#
		set m [expr {lSum($v)/$n}];
		return [expr {lSum([list $m $_m])}];
	};
	#
	#it estimates variance using a numerical list (and an optional mean) with "list size -1"
	proc var {list {m {}}} {
		# - $list: a numerical list
		# - $m: an optional mean value
		set v {};
		#n is list size
		set n [expr {double([llength $list])}];
		#
		#when the given list size is less than two
		if {$n<2} {return 0;};
		#
		#m is average of list
		set m [expr {[llength $m]>0?double($m):avg($list)}];
		foreach e $list {
			lappend v [expr {(double($e)-$m)**2}];
		};
		unset m;
		return [expr {lSum($v)/($n-1)}];
	};
};
#--------------------------------------------------------------------
#*** <namespace ::MCSS> ***
namespace eval ::MCSS {
	#=== variables ===
	#
	#M is number of resampling
	variable M 0;
	#
	#FREQLIST is a list of sample frequencies
	variable FREQLIST {};
	#
	#INFO is an array of summarized information
	variable INFO;
	array set INFO {};
	#
	#to initialize result lists
	#
	#sample size
	set INFO(sample_size) {};
	#
	#range of variable x
	set INFO(x_min) {};
	set INFO(x_max) {};
	set INFO(x_range) {};
	#
	#percentile scores
	set INFO(score_25) {};
	set INFO(score_50) {};
	set INFO(score_75) {};
	#
	#average, sample standard deviation and coefficient of variation
	set INFO(avg) {};
	set INFO(sample_std) {};
	set INFO(CV) {};
	#
	#moments
	set INFO(3rd_moment) {};
	set INFO(4th_moment) {};
	#
	#skewness, kurtosis and kurtosis_normal (where kurtosis of normal distribution is defined as 0)
	set INFO(skewness) {};
	set INFO(kurtosis) {};
	set INFO(kurtosis_normal) {};
	#
	#NOTE is an array of name and value
	variable NOTE;
	array set NOTE {};
	#
	#RANGE is the range of random value, [-4,4] is default
	variable RANGE {-4 4};
	#
	#FORMAT_STRING is a format string, `%.4f` is default  
	#See [`format`](https://www.tcl.tk/man/tcl8.6/TclCmd/format.html)
	variable FORMAT_STRING {%.4f};
	#
	#SOURCES is an array of paths to be included in output
	variable SOURCES;
	array set SOURCES {};
	#
	#--- Constant ---
	#=== Estimated Machine Epsilon ===
	variable EPSILON 0.5;
	while {1.0+$EPSILON!=1.0} {
		set EPSILON [expr {$EPSILON*0.5}];
	};
};
#
#it returns frequencies based on a given list
proc ::MCSS::getFreq list {
	# - $list: a numerical list
	#
	variable ::MCSS::FORMAT_STRING;
	#
	array set freq {};
	set result {};
	#
	foreach e $list {
		set E [format $::MCSS::FORMAT_STRING $e];
		#
		set freq($E) [expr {[llength [array names freq $E]]>0?$freq($E)+1:1}];
	};
	#
	set result [lsort -stride 2 -index 0 -real -increasing [array get freq]];
	unset freq;
	#
	return $result;
};
#
#it returns a pseudo-random floating-point value in a range [x1,x2], which is defined by $::MCSS::RANGE
proc ::MCSS::RANDOM {} {
	variable ::MCSS::RANGE;
	#
	#____________
	#u = random(0,1)
	#min = x1-1.0
	#max = x2+1.0
	#delta = max-min
	#v = min+delta*u
	#v := !(v<x1||v>x2)
	#____________
	#
	set x1 [expr {double([lindex $::MCSS::RANGE 0])}];
	set min [expr {$x1-1.0}];
	set x2 [expr {double([lindex $::MCSS::RANGE 1])}];
	set max [expr {$x2+1.0}];
	#
	set v [expr {$min+($max-$min)*rand()}];
	#
	while {$v<$x1||$v>$x2} {
		set v [expr {$min+($max-$min)*rand()}];
	};
	#
	unset x1 min x2 max;
	#
	return $v;
};
#
#it sets the format string and returns the current value
proc ::MCSS::SET_FORMAT {{formatString %.4f}} {
	# - $formatString: an optional format string, `%.4f` is default
	#
	variable ::MCSS::FORMAT_STRING;
	set ::MCSS::FORMAT_STRING $formatString;
	#
	return $::MCSS::FORMAT_STRING;
};
#
#it sets the range of random value and returns the current value
proc ::MCSS::SET_RANGE {x1 x2} {
	# - $x1 and $x2: a numerical range of random value
	#
	variable ::MCSS::RANGE;
	#
	set X1 [expr {$x1>$x2?$x2:$x1}];
	set X2 [expr {$x1>$x2?$x1:$x2}];
	#
	set ::MCSS::RANGE [list $X1 $X2];
	#
	unset X1 X2;
	#
	return $::MCSS::RANGE;
};
#
#it adds a note and returns a added values in a list (`{$name $value}`)
proc ::MCSS::ADD_NOTE {name value} {
	# - $name: name of a note
	# - $value: value of a note
	#
	variable ::MCSS::NOTE;
	#
	set namesList [array names ::MCSS::NOTE $name];
	#
	if {![llength $namesList]} {
		array set ::MCSS::NOTE [list $name $value];
	} else {
		set $::MCSS::NOTE($name) [expr {!(${name} in ${namesList})?${value}:[append ::MCSS::NOTE($name) "\u0020$value"]}];
	};
	#
	unset namesList;
	#
	return [list $name $value];
};
#
#it adds a file path to be included in output and returns added path
proc ::MCSS::INCLUDE path {
	# - $path: a file path to be included in output
	#
	variable ::MCSS::SOURCES;
	#---
	#
	set n [llength [array names ::MCSS::SOURCES]];
	#
	if {!$n} {
		array set ::MCSS::SOURCES {};
	};
	set ::MCSS::SOURCES($n) $path;
	unset n;
	#
	return $path;
};
#
#it is interface to input a single result of random simulation, and returns input list size
proc ::MCSS::INPUT list {
	# - $list: a numerical list
	#
	#when the given list size is less than one
	if {[llength $list]<1} {error "list size is less than 1";}
	#
	#=== variables ===
	variable ::MCSS::M;
	variable ::MCSS::FREQLIST;
	variable ::MCSS::INFO;
	variable ::MCSS::FORMAT_STRING;
	variable ::MCSS::EPSILON;
	#---
	#
	#a list of sample frequencies
	set freq {};
	#
	set _names {};
	set _values {};
	set _names_values {};
	set _nNames 0;
	set _n 0;
	#
	#percentile scores
	set _xMin 0.0;
	set _xMax 0.0;
	set _range 0.0;
	set _score25 0.0;
	set _score50 0.0;
	set _score75 0.0;
	#
	#moments
	set _d 0.0;
	set _M2 {};
	set _M3 {};
	set _M4 {};
	set _avg 0.0;
	set _std 0.0;
	set _moment3 0.0;
	set _moment4 0.0;
	set _skewness 0.0;
	set _kurtosis 0.0;
	#
	#the coefficient of variation
	set _cv 0.0;
	#
	set i 0;
	#---
	#
	#number of sample sets
	incr ::MCSS::M 1;
	#
	set freq [::MCSS::getFreq $list];
	lappend ::MCSS::FREQLIST $freq;
	#
	foreach {name value} $freq {
		lappend _names $name;
		lappend _values $value;
		#
		set i 0;
		while {$i<$value} {
			lappend _names_values $name;
			incr i 1;
		};
	};
	#
	set _nNames [llength $_names];
	#
	#--- $::MCSS::INFO ---
	#
	#sample size
	set _n [expr {lSum($_values)}];
	lappend ::MCSS::INFO(sample_size) $_n;
	#
	#range of variable x
	set _xMin [lindex $_names 0];
	lappend ::MCSS::INFO(x_min) $_xMin;
	#
	set _xMax [lindex $_names end];
	lappend ::MCSS::INFO(x_max) $_xMax;
	#
	set _range [expr {double($_xMax)-double($_xMin)}];
	lappend ::MCSS::INFO(x_range) $_range;
	#
	set _score25 [lindex $_names [expr {int(0.25*double($_nNames))}]];
	lappend ::MCSS::INFO(score_25) $_score25;
	#
	set _score50 [lindex $_names [expr {int(0.50*double($_nNames))}]];
	lappend ::MCSS::INFO(score_50) $_score50;
	#
	set _score75 [lindex $_names [expr {int(0.75*double($_nNames))}]];
	lappend ::MCSS::INFO(score_75) $_score75;
	#
	set _avg [expr {avg($_names_values)}];
	lappend ::MCSS::INFO(avg) $_avg;
	#
	#moments
	foreach {name value} $freq {
		set _d [expr {double($name)-$_avg}];
		#
		set i 0;
		while {$i<$value} {
			lappend _M2 [expr {$_d**2}];
			lappend _M3 [expr {$_d**3}];
			lappend _M4 [expr {$_d**4}];
			#
			incr i 1;
		};
	};
	#
	set _std [expr {sqrt(avg($_M2))}];
	lappend ::MCSS::INFO(sample_std) $_std;
	#
	set _cv [expr {!!$_avg?$_std/abs($_avg):$_std/$::MCSS::EPSILON}];
	lappend ::MCSS::INFO(CV) $_cv;
	#
	set _moment3 [expr {avg($_M3)}];
	lappend ::MCSS::INFO(3rd_moment) $_moment3;
	#
	set _moment4 [expr {avg($_M4)}];
	lappend ::MCSS::INFO(4th_moment) $_moment4;
	#
	set _skewness [expr {!!$_std?$_moment3/($_std**3):$_moment3/$::MCSS::EPSILON}];
	lappend ::MCSS::INFO(skewness) $_skewness;
	#
	set _kurtosis [expr {!!$_std?$_moment4/($_std**4):$_moment4/$::MCSS::EPSILON}];
	lappend ::MCSS::INFO(kurtosis) $_kurtosis;
	#
	set _kurtosis [expr {$_kurtosis-3.0}];
	lappend ::MCSS::INFO(kurtosis_normal) $_kurtosis;
	#
	#---
	unset freq _names _values _names_values _nNames _n _xMin _xMax _range _score25 _score50 _score75 _d _M2 _M3 _M4 _avg _std _moment3 _moment4 _skewness _kurtosis _cv i;
	#---
	return [llength $list];
};
#
#it returns metadata as a text in Markdown
proc ::MCSS::getMetadata {} {
	#
	#number of resampling
	variable ::MCSS::M;
	#
	#the range of random value
	variable ::MCSS::RANGE;
	#
	#format string
	variable ::MCSS::FORMAT_STRING;
	#
	#optional list of file paths to be included in output
	variable ::MCSS::SOURCES;
	#
	#other
	variable ::MCSS::NOTE;
	#
	#--- Constant ---
	#=== Machine Epsilon ===
	variable ::MCSS::EPSILON;
	#---
	#
	set result "\#\# Metadata";
	set i 0;
	set nSources [llength [array names ::MCSS::SOURCES]];
	#
	append result "\n- Resampling: \`$::MCSS::M\`";
	append result "\n- Random_range: \`[join $::MCSS::RANGE {,}]\`";
	append result "\n- Format_string: \`$::MCSS::FORMAT_STRING\`";
	#
	append result "\n\#\#\# Notes";
	foreach e [array names ::MCSS::NOTE] {
		append result "\n- ${e}: \`$::MCSS::NOTE($e)\`";
	};
	#
	append result "\n\#\#\# Sources";
	#
	set i 0;
	if {!!$nSources} {
		while {$i<$nSources} {
			append result "\n- \`[lindex [file split $::MCSS::SOURCES($i)] end]\`";
			incr i 1;
		};
	};
	#
	append result "\n\#\#\# Machine_epsilon";
	append result "\n- Machine_epsilon: \`$::MCSS::EPSILON\`";
	#
	unset i nSources;
	#
	return $result;
};
#
#it returns frequency distribution as a list (`{{name mean std} ...}`)
proc ::MCSS::getDist {} {
	variable ::MCSS::FREQLIST;
	#---
	#
	set result {\"x\" \"frequencies\" \"std\"};
	#
	array set _varArr {};
	set _names {};
	set _m 0.0;
	#
	foreach e $::MCSS::FREQLIST {
		foreach {name value} $e {
			lappend _varArr($name) $value;
		};
	};
	#
	set _names [lsort -real -increasing [array names _varArr]];
	#
	foreach e $_names {
		#
		set $_m 0.0;
		#
		lappend result $e;
		lappend result [set _m [expr {avg($_varArr($e))}]];
		lappend result [expr {sqrt(var($_varArr($e),$_m))}];
	};
	#
	unset _varArr _names _m;
	#
	return $result;
};
#
#it returns summarized information as a list (`{{name mean std} ...}`)
proc ::MCSS::getInfo {} {
	variable ::MCSS::INFO;
	#---
	#
	set arrNames {};
	set result {\"names\" \"values\" \"std\"};
	set _m 0.0;
	#
	#sample size
	lappend arrNames sample_size;
	#
	#range of variable x
	lappend arrNames x_min x_max x_range;
	#
	#percentile scores
	lappend arrNames score_25 score_50 score_75;
	#
	#average, sample standard deviation and coefficient of variation
	lappend arrNames avg sample_std CV;
	#
	#moments
	lappend arrNames 3rd_moment 4th_moment;
	#
	#skewness, kurtosis and kurtosis_normal (where kurtosis of normal distribution is defined as 0)
	lappend arrNames skewness kurtosis kurtosis_normal;
	#
	foreach e $arrNames {
		lappend result "\"$e\"";
		lappend result [set _m [expr {avg($::MCSS::INFO($e))}]];
		lappend result [expr {sqrt(var($::MCSS::INFO($e),$_m))}];
	};
	unset arrNames _m;
	#
	return $result;
};
#
#it resets variables in namespace `::MCSS`
proc ::MCSS::reset {} {
	#=== variables ===
	#
	#M is number of resampling
	variable ::MCSS::M 0;
	#
	#FREQLIST is a list of sample frequencies
	variable ::MCSS::FREQLIST {};
	#
	#INFO is an array of summarized information
	variable ::MCSS::INFO;
	unset ::MCSS::INFO;
	#
	variable ::MCSS::INFO;
	array set ::MCSS::INFO {};
	#
	#sample size
	set ::MCSS::INFO(sample_size) {};
	#
	#range of variable x
	set ::MCSS::INFO(x_min) {};
	set ::MCSS::INFO(x_max) {};
	set ::MCSS::INFO(x_range) {};
	#
	#percentile scores
	set ::MCSS::INFO(score_25) {};
	set ::MCSS::INFO(score_50) {};
	set ::MCSS::INFO(score_75) {};
	#
	#average, sample standard deviation and coefficient of variation
	set ::MCSS::INFO(avg) {};
	set ::MCSS::INFO(sample_std) {};
	set ::MCSS::INFO(CV) {};
	#
	#moments
	set ::MCSS::INFO(3rd_moment) {};
	set ::MCSS::INFO(4th_moment) {};
	#
	#skewness, kurtosis and kurtosis_normal (where kurtosis of normal distribution is defined as 0)
	set ::MCSS::INFO(skewness) {};
	set ::MCSS::INFO(kurtosis) {};
	set ::MCSS::INFO(kurtosis_normal) {};
	#
	#NOTE is an array of name and value
	variable ::MCSS::NOTE;
	unset ::MCSS::NOTE;
	#
	variable ::MCSS::NOTE;
	array set ::MCSS::NOTE {};
	#
	#RANGE is the range of random value, [-4,4] is default
	variable ::MCSS::RANGE {-4 4};
	#
	#FORMAT_STRING is a format string, `%.4f` is default  
	#See [`format`](https://www.tcl.tk/man/tcl8.6/TclCmd/format.html)
	variable ::MCSS::FORMAT_STRING {%.4f};
	#
	#SOURCES is an array of paths to be included in output
	variable ::MCSS::SOURCES;
	unset ::MCSS::SOURCES;
	#
	variable ::MCSS::SOURCES;
	array set ::MCSS::SOURCES {};
	#
	#--- Constant ---
	#=== Estimated Machine Epsilon ===
	variable ::MCSS::EPSILON 0.5;
	while {1.0+$::MCSS::EPSILON!=1.0} {
		set ::MCSS::EPSILON [expr {$::MCSS::EPSILON*0.5}];
	};
};
#
#it returns a keyword named after `$outputName` and generates a new directory, where to output three results and some additional sources
#	**three main results to output**
#		- `${outputName}_MCSS[numbers]_LOG.md`: log in Markdown file
#		- `${outputName}_MCSS[numbers]_INFO.csv`: summarized information in CSV file
#		- `${outputName}_MCSS[numbers]_DATA.csv`: frequency distribution in CSV file
#
proc ::MCSS::OUTPUT outputName {
	# - $outputName: a name for a keyword of the new directory to output
	#
	variable ::MCSS::SOURCES;
	#---
	#
	#the current time as an integer number of seconds
	set _t [clock seconds];
	#
	set i 0;
	set n 0;
	#
	set outputName "[regsub -all {[\s\t]} $outputName {_}]_MCSS${_t}";
	#
	#the timestamp
	set timestamp [clock format $_t];
	#
	#path for the current directory
	set dir0 [pwd];
	#
	#path for the directory
	set dir "${dir0}/${outputName}";
	#
	#channel
	set C {};
	set C_src {};
	#
	#markdown
	set _log [::MCSS::getMetadata];
	#
	#lists
	set _csvDist [::MCSS::getDist];
	set _csvInfo [::MCSS::getInfo];
	set _listBody {};
	set _listHead {};
	#=======================================
	#
	#generate a directory to output
	file mkdir $dir;
	#
	#=== output channel: log in markdown ===
	set C [open "${dir}/${outputName}_LOG.md" w];
	#
	puts -nonewline $C "\# LOG: \`${outputName}_LOG.md\`";
	puts -nonewline $C "\n- Timestamp: \`${timestamp}\`";
	puts -nonewline $C "\n- Time code: \`$_t\`";
	puts -nonewline $C "\n___";
	#
	puts -nonewline $C "\n${_log}";
	#
	puts -nonewline $C "\n___";
	#
	#--- table: info ---
	puts -nonewline $C "\n\# INFO: \[`${outputName}_INFO.csv\`\](${outputName}_INFO.csv)";
	#
	set _listHead [lrange $_csvInfo 0 2];
	set _listBody [lrange $_csvInfo 3 end];
	#
	puts -nonewline $C "\n|[lindex $_listHead 0]|[lindex $_listHead 1]|[lindex $_listHead 2]|";
	puts -nonewline $C "\n|---:|---:|---:|";
	#
	foreach {name value std} $_listBody {
		puts -nonewline $C "\n|${name}|${value}|${std}|";
	};
	#
	puts -nonewline $C "\n___";
	#
	#--- table: data ---
	puts -nonewline $C "\n\# DATA: \[`${outputName}_DATA.csv\`\](${outputName}_DATA.csv)";
	#
	set _listHead [lrange $_csvDist 0 2];
	set _listBody [lrange $_csvDist 3 end];
	#
	puts -nonewline $C "\n|[lindex $_listHead 0]|[lindex $_listHead 1]|[lindex $_listHead 2]|";
	puts -nonewline $C "\n|---:|---:|---:|";
	#
	#index: (0 to 9) *3 elements = (0 to 29)
	foreach {name value std} [lrange $_listBody 0 29] {
		puts -nonewline $C "\n|${name}|${value}|${std}|";
	};
	#
	if {[llength $_listBody]>30} {
		puts -nonewline $C "\n...";
		foreach {name value std} [lrange $_listBody end-2 end] {
			puts -nonewline $C "\n|${name}|${value}|${std}|";
		};
	};
	#
	close $C;
	#
	#=== output channel: info in csv ===
	set C [open "${dir}/${outputName}_INFO.csv" w];
	#
	set i 0;
	foreach {name value std} $_csvInfo {
		puts -nonewline $C "[expr {$i>0?"\n":{}}]${name},${value},${std}";
		incr i 1;
	};
	#
	close $C;
	#
	#=== output channel: data in csv ===
	set C [open "${dir}/${outputName}_DATA.csv" w];
	#
	set i 0;
	foreach {name value std} $_csvDist {
		puts -nonewline $C "[expr {$i>0?"\n":{}}]${name},${value},${std}";
		incr i 1;
	};
	#
	close $C;
	#
	#=== output channel: sources ===
	set i 0;
	set n [llength [array names ::MCSS::SOURCES]];
	if {!!$n} {
		while {$i<$n} {
			#
			set C_src [open $::MCSS::SOURCES($i) r];
			set C [open "${dir}/[lindex [file split $::MCSS::SOURCES($i)] end]" w];
			#
			fconfigure $C_src -encoding binary -translation binary;
			fconfigure $C -encoding binary -translation binary;
			#
			fcopy $C_src $C;
			#
			close $C_src;
			close $C;
			#
			incr i 1;
		};
	};
	#
	::MCSS::reset;
	unset _t i n timestamp dir0 dir C C_src _log _csvDist _csvInfo _listBody _listHead;
	#
	return $outputName;
};
#
