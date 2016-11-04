
using R to write a MATLAB function file
=======================================

I want to create MATLAB function files from R to support the reproducibility of MATLAB course materials written in R Markdown.

The idea is to:

-   write the lines of a MATLAB user-defined function as a R string
-   in R, write those lines to a text file `function.m`
-   eventually write a single R script that creates all my commonly used m-functions that I can `source()` from any Rmd

In MATLAB R2016b or later, multiple functions can be defined in a single script. However, my current plan is to create separate m-files for each function.

managing files
--------------

I use relative file paths with respect to the RStudio Project working directory. My examples require a file structure that includes:

    project\
      |-- derived\
      |-- results\
      |-- scripts\
      `-- project.Rproj

getting started
---------------

Create an Rmd script and save it to the `scripts/` directory.

``` r
library(knitr)
opts_knit$set(root.dir = "../")
```

Packages.

``` r
library(readr)
library(reach)
library(R.matlab)
```

Executed only if a MATLAB path error occurs.

``` r
add_to_path <- "pathstr = [cd]; 
  addpath(genpath(pathstr), '-end'); 
  savepath;" 
reach::runMatlabCommand(add_to_path)
```

write\_sys()
------------

My test-case MATLAB function, `write_sys.m`, writes a system transfer function to a text file. The function is based on the following code chunk from the Bode plot tutorial:

    % write sys to txt
    fid = fopen('results/sys_tf.txt', 'w');
    tfString = evalc('sys');
    fprintf(fid, '%s', tfString);
    fclose(fid);

I formulate formulate these lines as a MATLAB function in a string in the Rmd script. Use `cat()` to write the lines to a text file with a `.m` suffix in the `derived/` directory.

``` r
# user-defined MATLAB function
function_lines <- "function write_sys(sys, path)
  fid = fopen(path, 'wt');
  tf_string = evalc('sys');
  fprintf(fid, tf_string);
  fclose(fid);
  end
"
# write to file 
cat(function_lines, file = 'derived/write_sys.m', sep = '\n', append = FALSE)
```

The arguments are:

-   `sys` the result of the MATLAB `tf()` function
-   `path` the relative path and filename to be written

The `scripts/` directory should include this Rmd script. The `derived/` directory should have the m-file we just made.

test the function
-----------------

I'll create a transfer function for a first-order system and include the new function call, writing the transfer function to the `results/` directory.

``` r
m_script <- "% assign parameters
K  = 1;
wb = 0.5;

% create the transfer function 
n = K;
d = [1/wb  1];
sys = tf(n, d);

% write sys to txt
write_sys(sys, 'results/sys02.txt')
"
```

Then execute the m-file:

``` r
reach::runMatlabCommand(m_script)
Sys.sleep(12)
```

Read the text file produced by the function and print it.

``` r
sys <- read_lines('results/sys02.txt', skip = 3, n_max = 3)
cat(sys, sep = "\n")
```

         1
      -------
      2 s + 1

session info
------------

``` r
library(devtools)
session_info()
```

     setting  value                       
     version  R version 3.3.1 (2016-06-21)
     system   x86_64, mingw32             
     ui       RTerm                       
     language (EN)                        
     collate  English_United States.1252  
     tz       America/New_York            
     date     2016-11-04                  

     package     * version date       source                                 
     assertthat    0.1     2013-12-06 CRAN (R 3.2.1)                         
     devtools    * 1.12.0  2016-06-24 CRAN (R 3.3.1)                         
     digest        0.6.10  2016-08-02 CRAN (R 3.3.1)                         
     evaluate      0.10    2016-10-11 CRAN (R 3.3.1)                         
     htmltools     0.3.5   2016-03-21 CRAN (R 3.3.0)                         
     knitr       * 1.14.15 2016-11-03 Github (yihui/knitr@56faff4)           
     magrittr      1.5     2014-11-22 CRAN (R 3.2.1)                         
     memoise       1.0.0   2016-01-29 CRAN (R 3.2.3)                         
     R.matlab    * 3.6.1   2016-10-20 CRAN (R 3.3.1)                         
     R.methodsS3   1.7.1   2016-02-16 CRAN (R 3.2.3)                         
     R.oo          1.20.0  2016-02-17 CRAN (R 3.2.3)                         
     R.utils       2.4.0   2016-09-14 CRAN (R 3.3.1)                         
     Rcpp          0.12.7  2016-09-05 CRAN (R 3.3.1)                         
     reach       * 0.3.0   2015-10-17 Github (schmidtchristoph/reach@f503d44)
     readr       * 1.0.0   2016-08-03 CRAN (R 3.3.1)                         
     rmarkdown     1.1     2016-10-16 CRAN (R 3.3.1)                         
     stringi       1.1.2   2016-10-01 CRAN (R 3.3.1)                         
     stringr       1.1.0   2016-08-19 CRAN (R 3.3.1)                         
     tibble        1.2     2016-08-26 CRAN (R 3.3.1)                         
     withr         1.0.2   2016-06-20 CRAN (R 3.3.1)                         
     yaml          2.1.13  2014-06-12 CRAN (R 3.2.1)                         

------------------------------------------------------------------------

[main page](../README.md)
