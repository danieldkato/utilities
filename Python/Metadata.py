import subprocess
import json

class Metadata:
    def __init__(self):
        self.dict = { "inputs":[], \
                           "outputs":[], \
                           "parameters":[],\
                           "date": None,\
                           "time":None
        }

    def add_input(self, path):
        d = {"path":path}
        self.dict["inputs"].append(d)

    def add_output(self,path):
        d = {"path":path}
        self.dict["outputs"].append(d)
        

def write_metadata(Metadata, fname):
   
    # Get SHA1 checksums of all input and output files: 
    io = [Metadata.dict["inputs"], Metadata.dict["outputs"]] 
    for file_list in io:
        for f in file_list:
            sys_out = subprocess.check_output(['sha1sum',f["path"]])
            f["sha1"] = sys_out[0:40]

    # TODO: try to get software version information

    # Write object to json:
    with open(fname, 'w') as outfile:
        json.dump(Metadata.dict, outfile)
        
