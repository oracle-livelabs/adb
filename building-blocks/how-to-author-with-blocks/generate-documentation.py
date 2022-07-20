# This script generates the documentation for block services.
# It builds 2 things:
#   1. manifest.json
#   2. markdown file for each category
import os
import glob
import json
import re
from datetime import date

# Initialize
path_current   = os.path.dirname(os.path.realpath(__file__))
path_tasks     = path_current[:path_current.rfind("/")] + "/tasks"
relpath_blocks = "/building-blocks"
manifest_file  = path_current + "/manifest.json"
output = None

tasks = []

class Task:
    md_name = None    
    include_name = None
    name = None
    description = None
    path = None
    physical_path = None
    cloud_service = None
    dependencies = None

def write (s):
    global output

    if not output:
        output = s
    else:
        output = output + "\n" + s

# Populate list of tasks
def load_tasks():    
    files = sorted(filter( os.path.isfile, glob.glob(path_tasks + '/**/*.md', recursive=True)))
    
    for f in files:

        t = Task()
        t.physical_path = f
        t.md_name = f[f.rfind("/")+1:]
        t.path = f[f.rfind(relpath_blocks):]
        t.cloud_service = t.path[len(relpath_blocks + "/tasks/"):t.path.rfind("/")]
        t.include_name = t.cloud_service + "-" + t.md_name
        success = add_task_details(t)
        tasks.append(t)

# add the name and description of a task from its md file
def add_task_details(this_task):
    c = None  # file contents

    # read the file
    with open(this_task.physical_path) as f:
        c = f.read()
    
    c_begin = c.find("<!--")
    c_end   = c.find("-->")

    # bail if comments not found
    if c_begin == -1 or c_end == -1:
        print ("WARNING! " + this_task.md_name + ": no valid comment with name and description found.")
        return False

    # extract json from the first html comment found
    comment = c[c_begin+5:c_end-1].strip()
    # simple update to support "_" in MD. Requires HTML equivalent &lowbar;
    comment = comment.replace("_","&lowbar;")

    # parse the json
    j = None
    try:
        j = json.loads(comment, strict=False)
        this_task.name = j["name"]
        this_task.description = j["description"]
    except Exception as e:
        print ("WARNING! " + this_task.md_name + ": no valid comment with name and description found.")
        return False

    return True

#######
# write the manifest
#######
def write_manifest():
    global output

    write("{")
    write(' "workshoptitle":"LiveLabs Building Blocks",')
    write(' "include": {')
    for t in tasks:
        write('     "' + t.include_name + '":"' + t.path + '",')

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
    write('     {')
    write('         "title": "List of Building Blocks and Tasks",' )
    write('         "type": "freetier",' )
    write('         "filename": "' + relpath_blocks + '/how-to-author-with-blocks/all-tasks.md"' )
    write('     },')

    current_cloud_service = None
    for t in tasks:
        if t.cloud_service != current_cloud_service:
            current_cloud_service = t.cloud_service
            filename = relpath_blocks + "/how-to-author-with-blocks/" + t.cloud_service + ".md"
            write('     {')
            write('         "title": "' + t.cloud_service.upper() + ' Tasks",' )
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
# write the markdown file for the table of contents
###########
def write_toc():
    global output 

    output = None
    write("# List of Building Blocks and Tasks")
    write("## Introduction")
    write("")
    write("Review the list of Building Blocks and Tasks that are currently available. Become a contributor by creating reusable components!")
    write("## List of Building Blocks")
    write("")
    write("Building Blocks are exposed to customers. You can use these same blocks in your own workshop by adding the block to your manifest.json file.")
    write("")
    write("[Go here to view the list of Building Blocks](/building-blocks/workshop/freetier/index.html)")
    write("## List of Tasks")
    write("")
    write("List below are the tasks that you can incorporate into your markdown. You can also use the navigation tree on the left to view the tasks. Again, contribute to the list of tasks!")
    write("| Cloud Service | Task |  File | Description |")
    write("|---------------| ---- |  ---- |------------ |")


    for t in tasks:
        this_name = t.md_name if not t.name else t.name
        this_anchor = relpath_blocks + '/how-to-author-with-blocks/index.html?lab=' + t.cloud_service + '#' + re.sub('[^0-9a-zA-Z]+','', this_name)
        this_anchor = "[" + this_name + "](" + this_anchor + ")"
        this_description = t.description if t.description else " "
        write("| " + t.cloud_service + " | " + this_anchor + " | " + t.path + " | " + this_description + " |")

    h_mdfile = None
    h_mdfile = open(path_current + "/all-tasks.md", "w")
    h_mdfile.write(output)
    h_mdfile.close

    print(output)

###########
# write the markdown files for each cloud service tasks
###########
def write_cloud_service_tasks():
    global output

    current_cloud_service = None
    output = None
    h_mdfile = None
    for t in tasks:
        # Each cloud_service has its own markdown file
        if t.cloud_service != current_cloud_service:
            if h_mdfile:            
                # Write the markdown file output
                h_mdfile.write(output)
                h_mdfile.close
                print(output)
                output = None

            #Initialize the new markdown file
            h_mdfile = open(path_current + "/" + t.cloud_service + ".md", "w")       
            current_cloud_service = t.cloud_service
            
            write('# Block services: ' + t.cloud_service.upper())

        this_name = t.md_name if not t.name else t.name
        write('## ' + this_name)
        write('**Markdown file location:**')
        write("```")
        write(t.path)
        write("```")
        write("")
        write('**Add to your manifest.json:**')
        write("```")
        write('"include": {')
        write('     "' + t.include_name + '":"' + t.path + '",')
        write('}')
        write("```")
        write("")
        write("**Add to your workshop markdown:**")
        write("```")
        write("[]&lpar;include:" + t.md_name + ")")
        write("```")
        write("")
        write('**Markdown Output &#8595;&#8595;:**')
        write(" ")
        # [](include:adb-goto-sql-worksheet.md)
        write("[](include:" + t.include_name + ")")
        write(" ")

    h_mdfile.write(output)
    h_mdfile.close()    

def main():
    load_tasks()    
    write_manifest()
    write_toc()
    write_cloud_service_tasks()


if __name__ == "__main__":
    main()
