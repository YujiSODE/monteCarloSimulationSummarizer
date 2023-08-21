# monteCarloSimulationSummarizer
The Monte Carlo Simulation Summarizer (MCSS) is a tool to summarize results of random simulation.
___
GitHub: https://github.com/YujiSODE/monteCarloSimulationSummarizer  
>Copyright (c) 2023 Yuji SODE \<yuji.sode@gmail.com\>  
>This software is released under the MIT License.  
>See LICENSE or http://opensource.org/licenses/mit-license.php  
______

## Synopsis
This tool generates a new directory, where to output three results and some additional sources:  
**three main results to output**
- `${outputName}_MCSS[numbers]_LOG.md`: log in `Markdown` file
- `${outputName}_MCSS[numbers]_INFO.csv`: summarized information in `CSV` file
- `${outputName}_MCSS[numbers]_DATA.csv`: frequency distribution in `CSV` file


## Scripts
- [`monteCarloSimulationSummarizer.tcl`](monteCarloSimulationSummarizer.tcl)
- [`MCSS_INPUT.tcl`](MCSS_INPUT.tcl)
- [`MCSS_TEMPLATE_GEN.tcl`](MCSS_TEMPLATE_GEN.tcl)

## Library
- Sode, Y. 2018. lSum.tcl: https://gist.github.com/YujiSODE/1f9a4e2729212691972b196a76ba9bd0

## Compatibility
- Tcl `8.6+`
