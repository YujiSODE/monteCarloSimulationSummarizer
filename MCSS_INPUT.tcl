#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}
##===================================================================
#
#monteCarloSimulationSummarizer
#MCSS_INPUT.tcl
##===================================================================
#	Copyright (c) 2023 Yuji SODE <yuji.sode@gmail.com>
#
#	This software is released under the MIT License.
#	See LICENSE or http://opensource.org/licenses/mit-license.php
##===================================================================
#Shell interface for the Monte Carlo Simulation Summarizer (MCSS).
#
#=== Synopsis ===
# `tclsh MCSS_INPUT.tcl splitChar formatString values ?values ... values?`
# `MCSS_INPUT.tcl splitChar formatString values ?values ... values?`
#
#**arguments**
# - $splitChars: characters that are used to split each value of $values
# - $formatString: a format string using % conversion specifiers (e.g., `%.4f`)  
#   see [`format`](https://www.tcl.tk/man/tcl8.6/TclCmd/format.html)
# - $values: values that are joined by `$splitChars` (e.g., "value@value@...@value", which is joined by @)
#
##===================================================================
#
source -encoding utf-8 "[file dirname $argv0]/monteCarloSimulationSummarizer.tcl";
#
#$arg := {splitChar formatString values values ...}
proc _MCSS_INPUT arg {
	# - $arg := {splitChar formatString values values ...}
	#   - $splitChars: characters that are used to split each value of $values
	#   - $formatString: a format string using % conversion specifiers (e.g., `%.4f`)  
	#     See [`format`](https://www.tcl.tk/man/tcl8.6/TclCmd/format.html)
	#   - $values: values that are joined by `$splitChars` (e.g., "value@value@...@value", which is joined by @)
	#
	set chars [lindex $arg 0];
	#
	::MCSS::SET_FORMAT [lindex $arg 1];
	#
	foreach e [lrange $arg 2 end] {
		::MCSS::INPUT [split $e $chars];
	};
	#
	unset chars;
	#
	puts stdout [::MCSS::OUTPUT {MCSS_shellInput}];
};
#
if {$argc>2} {
	_MCSS_INPUT $argv;
}
exit;
#
