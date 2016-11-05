# r-matlab-toolbox functions

###
### R functions
###

# add project directories to the MATLAB search path
set_path <- function(...) {
  library(reach)
  m_script <- "pathstr = [cd];
    addpath(genpath(pathstr), '-end')
    savepath"
  reach::runMatlabCommand(m_script)
}

# execute the m-file for first run or if changed
run_mfile <- function(m_script) {
  library(reach)
  saveRDS(m_script, "derived/new.rds")
  if (!file.exists("derived/old.rds")) {
    saveRDS(" ", "derived/old.rds")
  }
  newrds <- readRDS("derived/new.rds")
  oldrds <- readRDS("derived/old.rds")
  if (!identical(oldrds, newrds)) {
    saveRDS(m_script, "derived/old.rds")
    reach::runMatlabCommand(m_script, verbose = FALSE, do_quit = TRUE)
    Sys.sleep(12)
  }
}

# print lines from an m-file
print_mfile <- function(m_script) {
  library(stringr)
  if (str_detect(m_script, "% print_stop")) {
    code_for_students <- str_split(m_script, "% print_stop", n = 2)[[1]][1]
  } else {
    code_for_students <- m_script
  }
    cat(code_for_students)
}

# print sys output from tf()
print_sys <- function(filepath) {
  library(readr)
  sys <- read_lines(filepath, skip = 3, n_max = 3)
  cat(sys, sep = "\n")
}

###
### write MATLAB functions
###

# write_sys.m
function_lines <- "
  function write_sys(sys, filepath)
    fid = fopen(filepath, 'wt');
    sys_string = evalc('sys');
    fprintf(fid, sys_string);
    fclose(fid);
  end
  "
cat(function_lines, file = 'derived/write_sys.m', sep = '\n', append = FALSE)

# write_gcf.m
function_lines <- "
  function write_gcf(gcf, filepath, width, height)
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 width height];
    saveas(fig, filepath);
  end
  "
cat(function_lines, file = 'derived/write_gcf.m', sep = '\n', append = FALSE)


