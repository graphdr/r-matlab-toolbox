
# find all Rmd scripts in the scripts directory
# compile them using uses rmarkdown::render()
# not as good as a makefile but does the job

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

# warning name is nonexistent or not  directory

# delete html files
unlink("scripts/*.html")
