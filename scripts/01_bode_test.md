
bode plot
=========

This example is about using the MATLAB `bode()` function.

The approach I've worked up here is to write an m-script in an R code chunk, have MATLAB run the code and save the outputs, and read the outputs into the R Markdown environment to create the course document.

managing files
--------------

I use relative file paths with respect to the RStudio Project working directory. My examples require a file structure that includes:

    project\
      |-- derived\
      |-- results\
      |-- scripts\
      `-- project.Rproj

I open an Rmd script and save it in the `scripts\` directory.

getting started
---------------

I set the `knitr` working directory to match the project working directory.

``` r
library(knitr)
opts_knit$set(root.dir = "../")
```

Load the packages.

``` r
library(readr)
library(stringr)
library(reach)
library(R.matlab)
```

The string variable `m_script` (below) contains the MATLAB commands to add the project folders to the MATLAB search path.

``` r
m_script <- "pathstr = cd;
  addpath(genpath(pathstr), '-end');
  savepath;"
reach::runMatlabCommand(m_script)
```

The header for this code chunk includes the knitr option `eval = FALSE`. If MATLAB indicates a path problem, e.g., `Warning: Name is nonexistent or not  directory...`, then I manually run the code chunk.

However, this code chunk adds all directories to the search path, including hidden directories such as `.git/` and `.Rproj.user/`. In later scripts, I show how to set the MATLAB path while excluding the hidden folders (see [`functions.R`](functions.R)).

authoring MATLAB code in the R script
-------------------------------------

This R code chunk contains the MATLAB script, surrounded by a single set of quotes and assigned to object `m_script`.

``` r
m_script <- "% assign parameters
K  = 1;
wn = 10; 
z  = 0.05;

% create the transfer function 
n = K;
d = [1/wn^2  2*z/wn  1];
sys = tf(n, d);

% compute and plot the frequency response
bode(sys)
grid
"# end m-file
```

To run the script in MATLAB:

``` r
reach::runMatlabCommand(m_script)
Sys.sleep(0)
```

Running this script, a MATLAB command window opens, the graph opens and closes, and the command window closes. The `Sys.sleep(0)` function has no effect here (set to 0 seconds) but will be used later.

Next we add some housekeeping code to be able to save the MATLAB output.

writing MATLAB output to file
-----------------------------

Add new lines to the `m_script` string following the `bode(sys)` line, starting with comment `% break`.

-   Lines above the break comment will be printed in the output document (code I want students to see and use); lines below are not.
-   the `% write sys to txt` chunk saves the transfer function `sys` to `'results/sys01.txt'`
-   the `% write gcf to png` chunk saves the graph to `'results/m01_bode.png'`

``` r
# MATLAB commands for a bode plot
m_script <- "% assign parameters
K  = 1;
wn = 10;
z  = 0.05; 

% create the transfer function 
n = K;
d = [1/wn^2  2*z/wn  1];
sys = tf(n, d);

% compute and plot the frequency response
bode(sys)
grid

% print_stop

% write sys to txt
fid = fopen('results/sys01.txt', 'wt');
sys_string = evalc('sys');
fprintf(fid, sys_string);
fclose(fid);

% write gcf to png
fig = gcf;
fig.PaperUnits    = 'inches';
fig.PaperPosition = [0 0 4 4];
saveas(fig, 'results/m01_bode.png');
"# end m-file
```

After knitting the document, the results directory has two files.

    results\
      |-- sys01.txt
      `-- m01_bode.png

printing the MATLAB code
------------------------

I use `str_split()` from the `stringr` package to separate the MATLAB commands at the `% print_stop` comment and print the upper half of the code to the output document for student use.

``` r
if (str_detect(m_script, "% print_stop")) {
  code_for_students <- str_split(m_script, "% print_stop", n = 2)[[1]][1]
} else {
  code_for_students <- m_script
}
cat(code_for_students)
```

The output printed to the document is:

    % assign parameters
    K  = 1;
    wn = 10;
    z  = 0.05; 

    % create the transfer function 
    n = K;
    d = [1/wn^2  2*z/wn  1];
    sys = tf(n, d);

    % compute and plot the frequency response
    bode(sys)
    grid

pause before reading
--------------------

Before reading the files from `results\` to place them in the Rmd output document, I edit `Sys.sleep()` to pause R execution for 12 seconds (your mileage may vary) to give MATLAB time to write outputs to file before R reads those files.

The revised code chunk for running MATLAB:

``` r
reach::runMatlabCommand(m_script)
Sys.sleep(12)
```

printing the transfer function
------------------------------

Read the MATLAB transfer function expression with `read_lines()` from the `readr` package. Select specific lines and print with `cat()`.

``` r
sys <- read_lines('results/sys01.txt', skip = 3, n_max = 3)
cat(sys, sep = "\n")
```

                1
      ---------------------
      0.01 s^2 + 0.01 s + 1

Or I can get fancy and pretty-print the transfer function,

``` r
# trim spaces and isolate the numerator and denominator 
Gs  <- str_trim(sys)
num <- Gs[1]
den <- Gs[3]
```

using inline code chunks in a math expression,

<pre class="r"><code>$$
G(s) = \frac{<code>`</code>r num<code>`</code>}{<code>`</code>r den<code>`</code>}
$$</code></pre>
Sadly, this syntax does not render properly when the R Markdown output format is set to `github_document`. However, it does render correctly to HTML, PDF, and Word output formats.

printing the bode plot
----------------------

The frequency response graph is obtained by reading the PNG file. Note that because `include_graphics()` does not honor the `root.dir = "../"` option set earlier, the path to the file name has to go up one level before finding the `results` directory.

``` r
knitr::include_graphics('../results/m01_bode.png')
```

<img src="../results/m01_bode.png" width="600" />

speeding up the run time
------------------------

Executing the MATLAB script is necessary only if the m-script changes. I can save run time by checking if the m-script has changed since the last time it was run.

This code chunk runs the MATLAB script for the first pass or if the MATLAB code has been changed. This chunk replaces the earlier lines `runMatlabCommand(m_script)` and `Sys.sleep(12)`. I still need the pause, but only when the m-file has been changed.

The `Sys.sleep(0)` function allows R to temporarily be given very low priority and hence not to interfere with more important foreground tasks. A typical use is to allow a process launched from R to set itself up and read its input files before R execution is resumed.

``` r
# save current version of m-script
saveRDS(m_script, "derived/m01-new.rds")

# create an empty RDS on the first pass
if (!file.exists("derived/m01-old.rds")) {
    saveRDS(" ", "derived/m01-old.rds")
}

# run MATLAB if old and new differ
newrds <- readRDS("derived/m01-new.rds")
oldrds <- readRDS("derived/m01-old.rds")
if (!identical(oldrds, newrds)) {
    saveRDS(m_script, "derived/m01-old.rds")
  runMatlabCommand(m_script)
  Sys.sleep(12)
}
```

coda
----

-   Several of the housekeeping tasks in this script have since been made into functions and saved in [`functions.R`](functions.R).
-   These functions are used in the [revised Bode plot](03_bode.md) tutorial.

session info
------------

     setting  value                       
     version  R version 3.3.1 (2016-06-21)
     system   x86_64, mingw32             
     ui       RStudio (0.99.902)          
     language (EN)                        
     collate  English_United States.1252  
     tz       America/New_York            
     date     2016-11-06                  

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
