
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

-   If you want a complete script to execute right now, copy and save [01\_bode\_test\_script.Rmd](01_bode_test_script.Rmd) as an Rmd script in the `scripts\` directory and knit.
-   If you want to assemble your Rmd script one element at a time, follow the steps below and knit the document after each step to see the output.

In either case, the explanations below describe my rationale for each code chunk in the final script.

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

The string variable `add_to_path` (below) contains the MATLAB commands to add the project folders to the MATLAB search path.

``` r
add_to_path <- "pathstr = [cd]; 
  addpath(genpath(pathstr), '-end'); 
  savepath;" 
reach::runMatlabCommand(add_to_path)
```

The header for this code chunk includes the knitr option `eval = FALSE`. If MATLAB indicates a path problem, I manually run the code chunk a time or two until the path message clears up.

authoring MATLAB code in the R script
-------------------------------------

This R code chunk contains the MATLAB script, surrounded by a single set of quotes and assigned to object `m_script`.

``` r
m_script <- "% assign parameters
K  = 5;
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
-   the `% write sys to txt` chunk saves the transfer function `sys` to `'results/sys_tf.txt'`
-   the `% write gcf to png` chunk saves the graph to `'results/m01_bode.png'`

``` r
# MATLAB commands for a bode plot
m_script <- "% assign parameters
K  = 5;
wn = 10;
z  = 0.05; 

% create the transfer function 
n = K;
d = [1/wn^2  2*z/wn  1];
sys = tf(n, d);

% compute and plot the frequency response
bode(sys)
grid

% break

% write sys to txt
fid = fopen('results/sys01.txt', 'w');
tfString = evalc('sys');
fprintf(fid, '%s', tfString);
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

I use `str_split()` from the `stringr` package to separate the MATLAB commands at the `% break` line and print the upper half of the code to the output document for student use.

``` r
code_for_students <- str_split(m_script, "% break", n = 2)[[1]][1]
cat(code_for_students)
```

The output printed to the document is:

    % assign parameters
    K  = 5;
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

                5
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
saveRDS(m_script, "derived/new.rds")

# create an empty RDS on the first pass
if (!file.exists("derived/old.rds")) {
    saveRDS(" ", "derived/old.rds")
}

# run MATLAB if old and new differ
newrds <- readRDS("derived/new.rds")
oldrds <- readRDS("derived/old.rds")
if (!identical(oldrds, newrds)) {
    saveRDS(m_script, "derived/old.rds")
  runMatlabCommand(m_script)
  Sys.sleep(12)
}
```

session info
------------

     setting  value                       
     version  R version 3.3.1 (2016-06-21)
     system   x86_64, mingw32             
     ui       RTerm                       
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
     rmarkdown     1.1     2016-10-16 CRAN (R 3.3.1)                         
     stringi       1.1.2   2016-10-01 CRAN (R 3.3.1)                         
     stringr     * 1.1.0   2016-08-19 CRAN (R 3.3.1)                         
     tibble        1.2     2016-08-26 CRAN (R 3.3.1)                         
     withr         1.0.2   2016-06-20 CRAN (R 3.3.1)                         
     yaml          2.1.13  2014-06-12 CRAN (R 3.2.1)                         

------------------------------------------------------------------------

[main page](../README.md)
