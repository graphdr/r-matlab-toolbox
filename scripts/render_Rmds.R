
# find all Rmd scripts in the scripts directory
# compile them using uses rmarkdown::render()
# not as good as a makefile but does the job

# once per session
source('scripts/functions.R')
# set_path()
# Sys.sleep(8)

#
# Warning: MATLAB Toolbox Path Cache is out of date and is not being used.
# Type 'help toolbox_path_cache' for more info


# package
library(rmarkdown)

#  identify the path to the directory we want
path_to_Rmds <- "scripts"

# find all files that end in .Rmd
Rmd_scripts <- list.files(
	path = path_to_Rmds
	, pattern = "\\.Rmd$"
	, full.names = TRUE
)

# render each script
sapply(Rmd_scripts, function(x) render(x))

# delete html files
unlink("scripts/*.html")



