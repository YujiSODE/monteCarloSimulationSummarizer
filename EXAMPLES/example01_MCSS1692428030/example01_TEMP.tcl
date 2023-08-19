#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}
##===================================================================#
#MCSS
#example01_TEMP.tcl
#
#=== MCSS ===
source -encoding utf-8 ../monteCarloSimulationSummarizer.tcl;
#
#=== notes ===
::MCSS::ADD_NOTE title example01;
::MCSS::ADD_NOTE comment "This is template sample file for the Monte Carlo Simulation Summarizer (MCSS).";
#
#=== format ===
::MCSS::SET_FORMAT %.1f;
#
#=== range of random variable ===
::MCSS::SET_RANGE -4 4;
#
#=== additional sources ===
#
#this file
::MCSS::INCLUDE example01_TEMP.tcl;
#
#=== data input ===
#command `::MCSS::INPUT` or Tcl script is available
#
#
::MCSS::INPUT {1 2 2 3 3 3 4 4 5};
#
::MCSS::INPUT {1 2 2 3 3 3 4 4 5};
#
::MCSS::INPUT {1 2 2 3 3 3 4 4 5};
#
#------------------
#
#=== output ===
puts stdout [::MCSS::OUTPUT example01];
::MCSS::reset;
#
puts stdout "#---- end ---";