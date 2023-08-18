# Change Log
# monteCarloSimulationSummarizer
## [Unreleased]

## [0.1 beta] - 2023-08-18
## Added
- [`MCSS_TEMPLATE_GEN.tcl`] lines 84 and 85:
  ```
	file attributes $tempName -permissions rwxrwxrwx;
	#
  ```

## Changed
- [`MCSS_TEMPLATE_GEN.tcl`] lines 89-91:  
  ```
  if {$argc>0} {
  	puts stdout [_MCSS_TEMP_GEN [lindex $argv 0] $argv0];
  }
  ```
- [`MCSS_TEMPLATE_GEN.tcl`] lines 84-86:  
  ```
	unset name dir dir0 temp C;
	#
	return $tempName;
  ```
- [`MCSS_TEMPLATE_GEN.tcl`] lines 80-82:  
  ```
	set C [open $tempName w];
	puts -nonewline $C $temp;
	close $C;
  ```
- [`MCSS_TEMPLATE_GEN.tcl`] line 66:  
  ```
  	append temp "\n\#command `::MCSS::INPUT` or Tcl script is available\n\#";
  ```
- [`MCSS_TEMPLATE_GEN.tcl`] line 62:  
  ```
  	append temp "\n::MCSS::INCLUDE ${tempName}\;";
  ```
- [`MCSS_TEMPLATE_GEN.tcl`] lines 36 and 37:  
  ```
	set temp "\#!/bin/sh\n\# the next line restarts using tclsh \\\nexec tclsh \"\$0\" \$\{1+\"\$@\"\}\n\#\#===================================================================";
	append temp "\#\n\#MCSS\n\#${tempName}";
  ```
- [`MCSS_TEMPLATE_GEN.tcl`] line 31:  
  ```
  	set tempName "${name}_TEMP.tcl";
  ```

## Added
- [`monteCarloSimulationSummarizer.tcl`] lines 765-767:
  ```
			close $C_src;
			close $C;
			#
  ```

## [0.1 beta] - 2023-08-14
## Added
- [`MCSS_TEMPLATE_GEN.tcl`]: added template generator

## Changed
- [`monteCarloSimulationSummarizer.tcl`] line 280: changed processes to deal with additional notes in `proc ::MCSS::ADD_NOTE`
- [`monteCarloSimulationSummarizer.tcl`] lines 18-21: changed some descriptions

## [0.1 beta] - 2023-08-12
## Added
- [`MCSS_INPUT.tcl`]: Shell interface for the Monte Carlo Simulation Summarizer (MCSS)

## Fixed
- [`monteCarloSimulationSummarizer.tcl`] `proc ::MCSS::INPUT`: calculations for sample average and moments were fixed

## [0.1 beta] - 2023-08-10
