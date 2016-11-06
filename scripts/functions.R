### R functions

# create directories if not exist
dir_create <- function(dir) {
  lapply(dir, function(x) {if (!dir.exists(x)) {dir.create(x)}})
}

# add current working directory to MATLAB search path
# this version does not use genpath_exclude.m
# set_path <- function(...) {
#   library(reach)
#   m_script <- "pathstr = [cd];
#     addpath(genpath(pathstr), '-end')
#     savepath"
#   reach::runMatlabCommand(m_script)
# }

# add current working directory to MATLAB search path
# obtain genpath_exclude() from MATLAB file exchange and save in scripts directory
# https://www.mathworks.com/matlabcentral/fileexchange/22209-genpath-exclude?s_tid=srchtitle
set_path <- function(...) {
	library(reach)
	m_script <- "addpath(fullfile(cd, 'scripts'), '-end');
  exclude_directories = {'\\..*', '*\\holding'};
	addpath(genpath_exclude(cd, exclude_directories), '-end')
	savepath"
	reach::runMatlabCommand(m_script, do_quit = TRUE)
}

# run MATLAB script listed as a string in R
run_mfile <- function(m_script, prefix = "m99", sec = 12) {
  library(reach)
  dir_create("derived")
  old_file <- paste0("derived/", prefix, "-old.rds")
  new_file <- paste0("derived/", prefix, "-new.rds")
  saveRDS(m_script, new_file)
  # if first run, create empty old_file
  if (!file.exists(old_file)) {saveRDS(" ", old_file)}
  oldrds <- readRDS(old_file)
  newrds <- readRDS(new_file)
  # run if file has changed since last run
  if (!identical(oldrds, newrds)) {
    saveRDS(m_script, old_file)
    reach::runMatlabCommand(m_script)
    Sys.sleep(sec)
  }
}

# print MATLAB script listed as a string in R
print_mfile <- function(m_script) {
  library(stringr)
  if (str_detect(m_script, "% print_stop")) {
    code_for_students <- str_split(m_script, "% print_stop", n = 2)[[1]][1]
  } else {
    code_for_students <- m_script
  }
    cat(code_for_students)
}

# print MATLAB tf() output written to .txt
print_sys <- function(filepath) {
  library(readr)
  sys <- read_lines(filepath, skip = 3, n_max = 3)
  cat(sys, sep = "\n")
}

# create an m-file from a MATLAB script listed as a string in R
make_m_file <- function(listing, filepath) {
	cat(listing, file = filepath, sep = '\n', append = FALSE)
}

### MATLAB functions

# write_sys.m
function_lines <- "
function write_sys(sys, filepath)
  fid = fopen(filepath, 'wt');
  sys_string = evalc('sys');
  fprintf(fid, sys_string);
  fclose(fid);
end
"
dir_create("derived")
make_m_file(function_lines, 'derived/write_sys.m')



# write_gcf.m
function_lines <- "
function write_gcf(gcf, filepath, width, height)
  fig = gcf;
  fig.PaperUnits = 'inches';
  fig.PaperPosition = [0 0 width height];
  saveas(fig, filepath);
end
"
dir_create("derived")
make_m_file(function_lines, 'derived/write_gcf.m')



