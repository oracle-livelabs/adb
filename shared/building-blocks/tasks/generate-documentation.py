# This script generates the documentation for block services.
# It builds 2 things:
#   1. manifest.json
#   2. markdown file for each category
import os
import glob
from datetime import date

# Initialize
path_area_start = os.path.dirname(os.path.realpath(__file__)) + "/"
blocks_path = "shared/building-blocks/tasks"
service_list_path = "shared/building-blocks/tasks/services"
output = None
files = sorted(filter( os.path.isfile, glob.glob(path_area_start + '**/*.md', recursive=True)))

services = []

class Service:
    name = None
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
    a = f.find(service_list_path)
    if f.find(service_list_path) >= 0:
        continue

    c = Service()
    c.name = f[f.rfind("/")+1:]
    c.path = f[f.rfind(blocks_path):]
    c.area = f[len(path_area_start):f.rfind("/")]
    services.append(c)
    

#######
# write the manifest
#######
write("{")
write(' "workshoptitle":"LiveLabs Building Blocks",')
write(' "include": {')
for c in services:
    write('     "' + c.name + '":"/' + c.path + '",')

output = output[:len(output)-1]

write(' },') # include
write(' "help": "livelabs-help-db_us@oracle.com",')
write(' "variables": ["/shared/building-blocks/variables/variables.json"],')
write(' "tutorials": [  ')
write('')
write('     {')
write('         "title": "Authoring using Blocks and Tasks",' )
write('         "type": "freetier",' )
write('         "filename": "/shared/building-blocks/how-to-author-with-blocks/how-to-author-with-blocks.md"' )
write('     },')

current_area = None
for c in services:
    if c.area != current_area:
        current_area = c.area
        filename = "/" + service_list_path + "/" + c.area + ".md"
        write('     {')
        write('         "title": "' + c.area.upper() + ' Tasks",' )
        write('         "type": "freetier",' )
        write('         "filename": "' + filename + '"' )
        write('     },')

output = output[:len(output)-1]    
write('  ]')
write('}')
print(output)

h_manifest = open(path_area_start + "/services/manifest.json", "w")
h_manifest.write(output)
h_manifest.close

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
        h_mdfile = open(path_area_start + "/services/" + c.area + ".md", "w")       
        current_area = c.area
        
        write('# Block services: ' + c.area.upper())

    write('## ' + c.name)
    write('**Manifest:**')
    write("```")
    write('"include": {')
    write('     "' + c.name + '":"/' + c.path + '"')
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
    write("[](include:" + c.name + ")")
    write(" ")

h_mdfile.write(output)
h_mdfile.close()