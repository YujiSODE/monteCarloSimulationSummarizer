#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}
##===================================================================
#
#monteCarloSimulationSummarizer
#MCSS_TEMPLATE_GEN.tcl
##===================================================================
#	Copyright (c) 2023 Yuji SODE <yuji.sode@gmail.com>
#
#	This software is released under the MIT License.
#	See LICENSE or http://opensource.org/licenses/mit-license.php
##===================================================================
#Shell interface of template generator for the Monte Carlo Simulation Summarizer (MCSS).
#
#=== Synopsis ===
# `tclsh MCSS_TEMPLATE_GEN.tcl name`
# `MCSS_TEMPLATE_GEN.tcl name`
#
#**arguments**
# - $name : a name for a template file
#
#output file is `"${name}_TEMP.tcl"`
##===================================================================
#
#$arg := {splitChar formatString values values ...}
proc _MCSS_TEMP_GEN {name dir} {
	# - $name : a name for a template file
	# - $dir : a path to the MCSS
	#
	set name [regsub -all {[\s\t]} $name {_}];
	set tempName "${name}_TEMP.tcl";
	#
	set dir [file dirname $dir];
	set dir0 [pwd];
	#
	set temp "\#!/bin/sh\n\# the next line restarts using tclsh \\\nexec tclsh \"\$0\" \$\{1+\"\$@\"\}\n\#\#===================================================================";
	append temp "\n\#\n\#MCSS\n\#${tempName}";
	#
	#channel to output
	set C {};
	#
	#path to the MCSS
	append temp "\n\#\n\#=== MCSS ===";
	append temp "\nsource -encoding utf-8 ${dir}/monteCarloSimulationSummarizer.tcl\;";
	#
	#note inputs
	append temp "\n\#\n\#=== notes ===";
	append temp "\n::MCSS::ADD_NOTE title ${name}\;";
	append temp "\n::MCSS::ADD_NOTE comment \"This is template sample file for the Monte Carlo Simulation Summarizer (MCSS).\"\;";
	#
	#format
	append temp "\n\#\n\#=== format ===";
	append temp "\n::MCSS::SET_FORMAT %.1f\;";
	#
	#range of random variable
	append temp "\n\#\n\#=== range of random variable ===";
	append temp "\n::MCSS::SET_RANGE -4 4\;";
	#
	#additional sources
	append temp "\n\#\n\#=== additional sources ===";
	append temp "\n\#\n\#this file";
	append temp "\n::MCSS::INCLUDE ${tempName}\;";
	#
	#data input
	append temp "\n\#\n\#=== data input ===";
	append temp "\n\#command `::MCSS::INPUT` or Tcl script is available\n\#";
	append temp "\n\#\n::MCSS::INPUT \{1 2 2 3 3 3 4 4 5\}\;";
	append temp "\n\#\n::MCSS::INPUT \{1 2 2 3 3 3 4 4 5\}\;";
	append temp "\n\#\n::MCSS::INPUT \{1 2 2 3 3 3 4 4 5\}\;";
	#
	append temp "\n\#\n\#------------------";
	#
	#here to generate a new directory and to output results
	append temp "\n\#\n\#=== output ===";
	append temp "\nputs stdout \[::MCSS::OUTPUT $name\]\;";
	append temp "\n::MCSS::reset\;";
	#
	append temp "\n\#\nputs stdout \"\#---- end ---\"\;";
	#
	set C [open "${dir0}/$tempName" w];
	puts -nonewline $C $temp;
	close $C;
	#
	file attributes $tempName -permissions rwxrwxrwx;
	#
	unset name dir dir0 temp C;
	#
	return $tempName;
};
#
if {$argc>0} {
	puts stdout [_MCSS_TEMP_GEN [lindex $argv 0] $argv0];
}
exit;
#
