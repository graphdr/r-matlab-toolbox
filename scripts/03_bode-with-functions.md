
bode plot
=========

Here, I update the bode plot script by placing housekeeping code chunks in `functions.R`, including R code chunks that write MATLAB function m-files.

``` r
# initialize knitr
library(knitr)
opts_knit$set(root.dir = "../")
opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, 
    fig.keep = 'high', comment = NA)
```

``` r
# load packages
library(readr)
library(stringr)
library(reach)
library(R.matlab)

# load the functions 
source('scripts/functions.R')
```

When running MATLAB from R, if the MATLAB Command window shows a path error message, type `set_path()` in the R Console.

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

% outputs
write_sys(sys, 'results/sys_tf.txt')
write_gcf(gcf, 'results/m01_bode.png', 4, 4)
"

# execute the m-file for first run or if changed
saveRDS(m_script, "derived/new.rds")
if (!file.exists("derived/old.rds")) {
    saveRDS(" ", "derived/old.rds")
}
newrds <- readRDS("derived/new.rds")
oldrds <- readRDS("derived/old.rds")
if (!identical(oldrds, newrds)) {
    saveRDS(m_script, "derived/old.rds")
  runMatlabCommand(m_script, verbose = FALSE, do_quit = TRUE)
  Sys.sleep(12)
}
```

Given an underdamped second-order system with gain *K*, natural frequency \(\omega_n\), and damping ratio \(\zeta\), the Bode plot for the system is created using the following MATLAB script.

``` r
code_for_students <- str_split(m_script, "% break", n = 2)[[1]][1]
cat(code_for_students)
```

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

The system transfer function is given by

``` r
sys <- read_lines('results/sys_tf.txt', skip = 3, n_max = 3)
# cat(sys, sep = "\n")

# trim spaces and isolate the numerator and denominator
Gs  <- str_trim(sys)
num <- Gs[1]
den <- Gs[3]
```

\[
G(s) = \frac{5}{0.01 s^2 + 0.01 s + 1}.
\]

The frequency response plot:

``` r
knitr::include_graphics('../results/m01_bode.png')
```

<img src="../results/m01_bode.png" width="600" />

------------------------------------------------------------------------

[main page](../README.md)
