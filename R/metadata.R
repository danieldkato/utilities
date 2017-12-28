# metadata.R

# DOCUMENTATION TABLE OF CONTENTS:
# I. OVERVIEW
# II. REQUIREMENTS
# III. INPUTS
# IV. OUTPUTS

# last updated DDK 2017-11-02

######################################################################################## 
# I. OVERVIEW:

# This function is for writing metadata to describe analyses performed using R.


######################################################################################## 
# II. REQUIREMENTS:

# 1) R.
# 2) The R package rjson. To install, call install.packages("rjson") from inside R.


######################################################################################## 
# III. INPUTS:

# 1) M - a list of lists containing metadata about the analysis performed by the calling
#    script. This list must minimally include the following elements:
#    
#	a) inputs - a list of lists representing files that somehow function as an 
#          input to the calling script. Each element of inputs  must minimally include
#          the named element `path`, whose value is the path to the corresponding input file.
#
#	b) outputs - same as inputs, but for output files saved by the calling function.


######################################################################################## 
# IV. OUTPUTS: 

# This function has no formal return, but saves to secondary storage a JSON file with 
# the following fields:

# 1) inputs - a list of files that function as some kind of input to the calling
#     script. Each element has a `path` field that gives its absolute path and
#     a `sha1` field that gives its SHA1 checksum.

# 2) outputs - same as above, except for output files saved by the calling script.

# 3) date - date of the analysis.

# 4) time - time of the analysis (specifically the time this function is called, which
#    probably be after the analysis is complete).


######################################################################################## 
# TODO: 
# Try to find software dependencies of calling script and find version information.


######################################################################################## 


library("rjson")

metadata <- function(M, output_path){

	# Get checksums for inputs:
	for (file in M$inputs){
		sys_out = system(paste("sha1sum",file$path,sep=" "),intern=TRUE)
		file$sha1 = substr(sys_out,1,40)
	}

	# Get checksums for outputs:
	for (file in M$outputs){
		sys_out = system(paste("sha1sum",file$path,sep=" "),intern=TRUE)
		file$sha1 = substr(sys_out,1,40)
	}

	#TODO: get software version information

	# Get date and time:
	now = Sys.time()
	M$date = format(now,format="%Y-%m-%d")
	M$time = format(now,format="%H:%M:%S")

	#Write as JSON:
	J <- toJSON(M)
	wriate(J,file=output_path)
}
