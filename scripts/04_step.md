
step response
=============

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
# step response m-file
m_script <- "% assign parameters
K  = 1;
wn = 100;
z  = 0.5;

% create the transfer function
n = K;
d = [1/wn^2  2*z/wn  1];
sys = tf(n, d);

% compute and plot the unit step response
step(sys)
grid

% print_stop 

% save results
write_sys(sys, 'results/sys_tf.txt')
write_gcf(gcf, 'results/m04_step.png', 6, 4)
"# end m-file
```

Run the m-file.

The function `run_mfile()` launches MATLAB only if the code has changed since the last run or if this run is the first. To force the code to run, delete the `derived/old.rds` file (if it exists).

``` r
# run the m-file if necessary
run_mfile(m_script)
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

    % compute and plot the unit step response
    step(sys)
    grid

``` r
# print the sys tfansfer function from tf()
print_sys('results/sys_tf.txt')
```

                 1
      -----------------------
      0.0001 s^2 + 0.01 s + 1

``` r
# print the graph
knitr::include_graphics('../results/m04_step.png')
```

<img src="../results/m04_step.png" width="900" />

------------------------------------------------------------------------

[main page](../README.md)
