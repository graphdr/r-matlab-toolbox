### R functions

# create directories if not exist
dir_create <- function(dir) {
  lapply(dir, function(x) {if (!dir.exists(x)) {dir.create(x)}})
}

# add project directories to the MATLAB search path
set_path <- function(...) {
  library(reach)
  m_script <- "pathstr = [cd];
    addpath(genpath(pathstr), '-end')
    savepath"
  reach::runMatlabCommand(m_script)
}

# execute the m-file for first run or if changed
run_mfile <- function(m_script, prefix) {
  library(reach)
	dir_create("derived")
	old_path <- paste0("derived/", prefix, "-old.rds")
	new_path <- paste0("derived/", prefix, "-new.rds")
  saveRDS(m_script, new_path)
  if (!file.exists(old_path)) {
    saveRDS(" ", old_path)
  }
  newrds <- readRDS(new_path)
  oldrds <- readRDS(old_path)
  if (!identical(oldrds, newrds)) {
    saveRDS(m_script, old_path)
    reach::runMatlabCommand(m_script)
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

# create an m-file
make_m_file <- function(function_lines, filepath) {
	cat(function_lines, file = filepath, sep = '\n', append = FALSE)
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









