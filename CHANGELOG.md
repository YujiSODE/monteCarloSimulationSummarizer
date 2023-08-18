# Change Log
# monteCarloSimulationSummarizer
## [Unreleased]


## [0.1 beta] - 2023-08-18
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
