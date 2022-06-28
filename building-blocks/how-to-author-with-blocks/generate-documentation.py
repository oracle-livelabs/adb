# This script generates the documentation for block services.
# It builds 2 things:
#   1. manifest.json
#   2. markdown file for each category
import os
import glob
from datetime import date

# Initialize
path_current   = os.path.dirname(os.path.realpath(__file__))
path_tasks     = path_current[:path_current.rfind("/")] + "/tasks"
relpath_blocks = "/building-blocks"
manifest_file  = path_current + "/manifest.json"

output = None
files = sorted(filter( os.path.isfile, glob.glob(path_tasks + '/**/*.md', recursive=True)))

services = []

class Service:
    name = None
    include_name = None
    path = None
    area = None

def write (s):
    global output

    if not output:
        output = s
    else:
        output = output + "\n" + s


# Populate list of services
for f in files:

    c = Service()
    c.name = f[f.rfind("/")+1:]
    c.path = f[f.rfind(relpath_blocks):]
    c.area = c.path[len(relpath_blocks + "/tasks/"):c.path.rfind("/")]
    c.include_name = c.area + "-" + c.name
    services.append(c)
    

#######
# write the manifest
#######
write("{")
write(' "workshoptitle":"LiveLabs Building Blocks",')
write(' "include": {')
for c in services:
    write('     "' + c.include_name + '":"' + c.path + '",')

output = output[:len(output)-1]

write(' },') # include
write(' "help": "livelabs-help-db_us@oracle.com",')
write(' "variables": ["' + relpath_blocks + '/variables/variables.json"],')
write(' "tutorials": [  ')
write('')
write('     {')
write('         "title": "Authoring using Blocks and Tasks",' )
write('         "type": "freetier",' )
write('         "filename": "' + relpath_blocks + '/how-to-author-with-blocks/how-to-author-with-blocks.md"' )
write('     },')

current_area = None
for c in services:
    if c.area != current_area:
        current_area = c.area
        filename = relpath_blocks + "/how-to-author-with-blocks/" + c.area + ".md"
        write('     {')
        write('         "title": "' + c.area.upper() + ' Tasks",' )
        write('         "type": "freetier",' )
        write('         "filename": "' + filename + '"' )
        write('     },')

output = output[:len(output)-1]    
write('  ]')
write('}')
print(output)
try:    
    h_manifest = open(manifest_file, "w")
    h_manifest.write(output)
    h_manifest.close
except Exception as e:
    print (type(e))
    print (str(e))

###########
# write the markdown files
###########
current_area = None
output = None
h_mdfile = None
for c in services:
    # Each area has its own markdown file
    if c.area != current_area:
        if h_mdfile:            
            # Write the markdown file output
            h_mdfile.write(output)
            h_mdfile.close
            print(output)
            output = None

        #Initialize the new markdown file
        h_mdfile = open(path_current + "/" + c.area + ".md", "w")       
        current_area = c.area
        
        write('# Block services: ' + c.area.upper())

    write('## ' + c.name)
    write('**Manifest:**')
    write("```")
    write('"include": {')
    write('     "' + c.include_name + '":"' + c.path + '",')
    write('}')
    write("```")
    write("")
    write("**Markdown:**")
    write("```")
    write("[]&lpar;" + c.name + ")")
    write("```")
    write("")
    write('**Markdown Output &#8595;&#8595;:**')
    write(" ")
    # [](include:adb-goto-sql-worksheet.md)
    write("[](include:" + c.include_name + ")")
    write(" ")

h_mdfile.write(output)
h_mdfile.close()