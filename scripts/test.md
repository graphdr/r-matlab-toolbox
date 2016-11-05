
bode plot
=========

initialize
----------

``` r
library(knitr)
opts_knit$set(root.dir = "../")
opts_chunk$set(echo = TRUE, comment = NA, message = FALSE)
```

``` r
library(readr)
library(stringr)
library(reach)
library(R.matlab)
```

``` r
add_to_path <- "pathstr = [cd];
  addpath(genpath(pathstr), '-end');
  savepath;"
reach::runMatlabCommand(add_to_path)
```

m-file
------

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

# execute the m-file for first run or if changed
saveRDS(m_script, "derived/new.rds")

# create empty RDS if old does not exist
if (!file.exists("derived/old.rds")) {
    saveRDS(" ", "derived/old.rds")
}

# execute
newrds <- readRDS("derived/new.rds")
oldrds <- readRDS("derived/old.rds")
if (!identical(oldrds, newrds)) {
    saveRDS(m_script, "derived/old.rds")
  runMatlabCommand(m_script, verbose = FALSE, do_quit = TRUE)
  Sys.sleep(12)
}
```

results
-------

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

``` r
sys <- read_lines('results/sys01.txt', skip = 3, n_max = 3)
cat(sys, sep = "\n")
```

                5
      ---------------------
      0.01 s^2 + 0.01 s + 1

``` r
knitr::include_graphics('../results/m01_bode.png')
```

<img src="../results/m01_bode.png" width="600" />
