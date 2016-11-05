
bode plot
=========

Requires `functions.R` and a directory structure that includes:

    project\
      |-- derived\
      |-- results\
      |-- scripts\
      `-- project.Rproj

initialize
----------

Create an Rmd script in `scripts/`. Initialize knitr.

``` r
library(knitr)
opts_knit$set(root.dir = "../")
opts_chunk$set(echo = TRUE, comment = NA, message = FALSE)
```

Sourcing `functions.R` loads my R functions and writes user-defined MATLAB functions to file in the `derived/` directory.

``` r
source('scripts/functions.R')
```

m-file
------

Write the m-file.

The optional comment `% print_stop` separates lines above for printing (code I want students to see) from lines below (concealed from students) when printing code using `print_mfile()`.

``` r
# MATLAB commands for a bode plot
m_script <- "% assign parameters
K  = 1;
wn = 100;
z  = 0.5;

% create the transfer function
n = K;
d = [1/wn^2  2*z/wn  1];
sys = tf(n, d);

% compute and plot the frequency response
bode(sys)
grid

% print_stop 

% save results
write_sys(sys, 'results/sys03.txt')
write_gcf(gcf, 'results/m03_bode.png', 6, 6)
"# end m-file
```

Run the m-file.

The function `run_mfile()` launches MATLAB only if the code has changed since the last run or if this run is the first. To force the code to run, delete the `derived/old.rds` file (if it exists).

``` r
# run the m-file if necessary
run_mfile(m_script, "m03")
```

If, when running MATLAB from R, the Command window shows a "path" warning, run `set_path()`.

results
-------

Finally, print the code I want students to see, the transfer function, and the Bode plot.

``` r
# print the m-file up to the line % print_stop
print_mfile(m_script)
```

    % assign parameters
    K  = 1;
    wn = 100;
    z  = 0.5;

    % create the transfer function
    n = K;
    d = [1/wn^2  2*z/wn  1];
    sys = tf(n, d);

    % compute and plot the frequency response
    bode(sys)
    grid

``` r
# print the sys tfansfer function from tf()
print_sys('results/sys03.txt')
```

                 1
      -----------------------
      0.0001 s^2 + 0.01 s + 1

``` r
# print the graph
knitr::include_graphics('../results/m03_bode.png')
```

<img src="../results/m03_bode.png" width="900" />

session info
------------

``` r
library(devtools)
session_info()
```

     setting  value                       
     version  R version 3.3.1 (2016-06-21)
     system   x86_64, mingw32             
     ui       RStudio (0.99.902)          
     language (EN)                        
     collate  English_United States.1252  
     tz       America/New_York            
     date     2016-11-05                  

     package     * version date       source                                 
     assertthat    0.1     2013-12-06 CRAN (R 3.2.1)                         
     devtools    * 1.12.0  2016-06-24 CRAN (R 3.3.1)                         
     digest        0.6.10  2016-08-02 CRAN (R 3.3.1)                         
     evaluate      0.10    2016-10-11 CRAN (R 3.3.1)                         
     htmltools     0.3.5   2016-03-21 CRAN (R 3.3.0)                         
     knitr       * 1.14.15 2016-11-03 Github (yihui/knitr@56faff4)           
     magrittr      1.5     2014-11-22 CRAN (R 3.2.1)                         
     memoise       1.0.0   2016-01-29 CRAN (R 3.2.3)                         
     png           0.1-7   2013-12-03 CRAN (R 3.3.0)                         
     R.matlab    * 3.6.1   2016-10-20 CRAN (R 3.3.1)                         
     R.methodsS3   1.7.1   2016-02-16 CRAN (R 3.2.3)                         
     R.oo          1.20.0  2016-02-17 CRAN (R 3.2.3)                         
     R.utils       2.4.0   2016-09-14 CRAN (R 3.3.1)                         
     Rcpp          0.12.7  2016-09-05 CRAN (R 3.3.1)                         
     reach       * 0.3.0   2015-10-17 Github (schmidtchristoph/reach@f503d44)
     readr       * 1.0.0   2016-08-03 CRAN (R 3.3.1)                         
     rmarkdown   * 1.1     2016-10-16 CRAN (R 3.3.1)                         
     rsconnect     0.4.3   2016-05-02 CRAN (R 3.3.0)                         
     rstudioapi    0.6     2016-06-27 CRAN (R 3.3.1)                         
     stringi       1.1.2   2016-10-01 CRAN (R 3.3.1)                         
     stringr     * 1.1.0   2016-08-19 CRAN (R 3.3.1)                         
     tibble        1.2     2016-08-26 CRAN (R 3.3.1)                         
     withr         1.0.2   2016-06-20 CRAN (R 3.3.1)                         
     yaml          2.1.13  2014-06-12 CRAN (R 3.2.1)                         

------------------------------------------------------------------------

[main page](../README.md)
