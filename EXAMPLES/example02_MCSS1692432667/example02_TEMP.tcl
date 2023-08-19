#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}
##===================================================================#
#MCSS
#example02_TEMP.tcl
#
#=== MCSS ===
source -encoding utf-8 ../monteCarloSimulationSummarizer.tcl;
#
#=== notes ===
::MCSS::ADD_NOTE title example01;
::MCSS::ADD_NOTE comment "This is template sample file for the Monte Carlo Simulation Summarizer (MCSS).";
::MCSS::ADD_NOTE method "normally distributed random numbers by Box–Muller transform.";
#
::MCSS::ADD_NOTE reference1 {Box, G.E.P. and Muller, M.E. 1958. A Note on the Generation of Random Normal Deviates. Ann. Math. Statist. 29 (2), 610-611. DOI: 10.1214/aoms/1177706645};
::MCSS::ADD_NOTE reference1_src {https://projecteuclid.org/journals/annals-of-mathematical-statistics/volume-29/issue-2/A-Note-on-the-Generation-of-Random-Normal-Deviates/10.1214/aoms/1177706645.full};
#
#=== format ===
::MCSS::SET_FORMAT %.1f;
#
#=== range of random variable ===
::MCSS::SET_RANGE 0.0003 0.9993;
#
#=== additional sources ===
#
#this file
::MCSS::INCLUDE example02_TEMP.tcl;
#
#=== data input ===
#command `::MCSS::INPUT` or Tcl script is available
#
set i 0;
set j 0;
#
set m 200.0;
set sampleSize 0;
#
set N 100;
#
set u1 0.0;
set u2 0.0;
#
set PI2 [expr {2.0*3.141592653589793}];
#
set v {};
#
while {$i<$N} {
	#
	set j 0;
	set v {};
	#
	set sampleSize [expr {50+int($m*rand())}];
	#
	while {$j<$sampleSize} {
		#
		set u1 [::MCSS::RANDOM];
		set u2 [::MCSS::RANDOM];
		#
		lappend v [expr {sqrt(-2.0*log($u1))*cos($PI2*$u2)}];
		#
		incr j 1;
	};
	#
	::MCSS::INPUT $v;
	#
	incr i 1;
};
#
#------------------
#
#=== output ===
puts stdout [::MCSS::OUTPUT example02];
::MCSS::reset;
#
puts stdout "#---- end ---";
