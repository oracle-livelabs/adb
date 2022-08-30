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
### get physical paths - required to write manifest files and markdown
path_current   = os.path.dirname(os.path.realpath(__file__))
path_root      = path_current[:path_current.rfind("building-blocks")] + "building-blocks"
path_howto     = path_root + "/how-to-author-with-blocks"
path_tasks     = path_root + "/tasks"
path_blocks    = path_root + "/blocks"

# relative path used for forming URLs
relpath_blocks = "/adb/building-blocks"

tasks = []
blocks = []

# Tasks and blocks currently have the same properties. 
# Using two classes because this may change
class Lab:
    md_name = None    
    include_name = None
    name = None
    description = None
    path = None
    physical_path = None
    cloud_service = None
    dependencies = None
  

# helper function simply adds a line to a string
def add_line (input_string, line):
    return_string = None
    
    if not input_string:
        return_string = line
    else:
        return_string = input_string + "\n" + line
    
    return return_string

# Populate list of labs (blocks or tasks)
def load_labs(type):    

    this_path = None
    if type == "blocks":
        this_path = path_blocks
    else:
        this_path = path_tasks

    files = sorted(filter( os.path.isfile, glob.glob(this_path + '/**/*.md', recursive=True)))
    
    for f in files:

        t = Lab()
        t.physical_path = f
        t.md_name = f[f.rfind("/")+1:]
        t.path = f[f.rfind(relpath_blocks):]

        # get the service name from the path. 
        s = t.physical_path[len(this_path)+1:]
        t.cloud_service = s[:s.find("/")]

        t.include_name = t.cloud_service + "-" + t.md_name
        
        if type == "blocks":
            add_block_details(t)
            blocks.append(t)
        else:
            add_task_details(t)
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

# Populate list of blocks (this is currently identical to Tasks - may change)
def load_blocks():    
    files = sorted(filter( os.path.isfile, glob.glob(path_blocks + '/**/*.md', recursive=True)))
    
    for f in files:

        t = Lab()
        t.physical_path = f
        t.md_name = f[f.rfind("/")+1:]
        t.path = f[f.rfind(relpath_blocks):]
        success = add_block_details(t)

        # get the service name from the path. 
        s = t.physical_path[len(path_blocks)+1:]
        t.cloud_service = s[:s.find("/")]

        blocks.append(t)

# add the name and description of a task from its md file
def add_block_details(this_block):
    c = None  # file contents

    # read the file
    with open(this_block.physical_path) as f:
        c = f.read()
    
    c_begin = c.find("<!--")
    c_end   = c.find("-->")

    # If comments not found, use the first header field to populate the name
    if c_begin == -1 or c_end == -1:
        h1 = getFirstH1(c)
        if not h1:
            this_block.name = "Not Found. Fix markdown file " + this_block.path
            this_block.description = "No description found."
            return False
        print ("WARNING! " + this_block.md_name + ": no valid comment with name and description found.")
        this_block.name = h1
        this_block.description = "No description found."
        
    else:
        # extract json from the first html comment found
        comment = c[c_begin+5:c_end-1].strip()
        # simple update to support "_" in MD. Requires HTML equivalent &lowbar;
        comment = comment.replace("_","&lowbar;")

        # parse the json
        j = None
        try:
            j = json.loads(comment, strict=False)
            this_block.name = j["name"]
            this_block.description = j["description"]
        except Exception as e:
            print ("WARNING! " + this_block.md_name + ": no valid comment with name and description found.")
            return False

    return True    

def getFirstH1 (doc):
    h1_string = None

    for line in doc.split("\n"):
        if line[0:1] == "#":
            h1_string = line[1:].strip()
            break
    
    return h1_string


def get_manifest_include():
    include = None
    
    include = ' "include": {' + "\n"
    for t in tasks:
        include = include + '     "' + t.include_name + '":"' + t.path + '",\n'

    include = include[:len(include)-2]

    include = include + ('\n  },') # include

    return include

# Return a manifest template that can be copied and pasted
def get_manifest_template():

    output = '''{
  "workshoptitle":"LiveLabs Workshop Template",'''
    output = add_line(output, " " + get_manifest_include())
    output = output + '''\n  "help": "livelabs-help-db_us@oracle.com",
  "variables": ["./variables.json"],
  "tutorials": [  
    {
        "title": "Get Started",
        "description": "Get a Free Trial",
        "filename": "https://raw.githubusercontent.com/oracle/learning-library/master/common/labs/cloud-login/cloud-login.md"
    },
    {
        "title": "Provision Autonomous Database",
        "type": "freetier",
        "filename": "/adb/building-blocks/blocks/adb/provision/provision-console.md"
    },
    {
        "title": "Your lab goes here",
        "type": "freetier",
        "filename": "/../../yourlab.md"
    }
  ]
}''' 

    return output  


#######
# write the task manifest in for the how-to-author-with-blocks
#######
def write_task_manifest():
    output = None

    output = add_line(output, "{")
    output = add_line(output, ' "workshoptitle":"LiveLabs Building Blocks",')
    output = add_line(output, get_manifest_include())
    output = add_line(output, ' "help": "livelabs-help-db_us@oracle.com",')
    output = add_line(output, ' "variables": ["' + relpath_blocks + '/variables/variables.json"],')
    output = add_line(output, ' "tutorials": [  ')
    output = add_line(output, '')
    output = add_line(output, '     {')
    output = add_line(output, '         "title": "Authoring using Blocks and Tasks",' )
    output = add_line(output, '         "type": "freetier",' )
    output = add_line(output, '         "filename": "' + relpath_blocks + '/how-to-author-with-blocks/how-to-author-with-blocks.md"' )
    output = add_line(output, '     },')
    output = add_line(output, '     {')
    output = add_line(output, '         "title": "Creating Blocks and Tasks",' )
    output = add_line(output, '         "type": "freetier",' )
    output = add_line(output, '         "filename": "' + relpath_blocks + '/how-to-author-with-blocks/creating-blocks-tasks.md"' )
    output = add_line(output, '     },')
    output = add_line(output, '     {')
    output = add_line(output, '         "title": "List of Building Blocks and Tasks",' )
    output = add_line(output, '         "type": "freetier",' )
    output = add_line(output, '         "filename": "' + relpath_blocks + '/how-to-author-with-blocks/all-blocks-tasks.md"' )
    output = add_line(output, '     },')

    current_cloud_service = None
    for t in tasks:
        if t.cloud_service != current_cloud_service:
            current_cloud_service = t.cloud_service
            filename = relpath_blocks + "/how-to-author-with-blocks/" + t.cloud_service + ".md"
            output = add_line(output, '     {')
            output = add_line(output, '         "title": "' + t.cloud_service.upper() + ' Tasks",' )
            output = add_line(output, '         "type": "freetier",' )
            output = add_line(output, '         "filename": "' + filename + '"' )
            output = add_line(output, '     },')

    output = output[:len(output)-1]    
    output = add_line(output, '  ]')
    output = add_line(output, '}')
    print(output)
    try:    
        h_manifest = open(path_howto + "/workshop/manifest.json", "w")
        h_manifest.write(output)
        h_manifest.close
    except Exception as e:
        print (type(e))
        print (str(e))

#######
# write the blocks manifest in for the customer facing Building Blocks
#######
def write_blocks_manifest():
    output = None

    output = add_line(output, "{")
    output = add_line(output, ' "workshoptitle":"LiveLabs Building Blocks",')
    output = add_line(output, get_manifest_include())
    output = add_line(output, ' "help": "livelabs-help-db_us@oracle.com",')
    output = add_line(output, ' "variables": ["' + relpath_blocks + '/variables/variables.json"],')
    output = add_line(output, ' "tutorials": [  ')
    output = add_line(output, '')
    output = add_line(output, '     {')
    output = add_line(output, '         "title": "Get Started",' )
    output = add_line(output, '         "description": "Get a Free Trial",' )
    output = add_line(output, '         "filename": "https://raw.githubusercontent.com/oracle/learning-library/master/common/labs/cloud-login/cloud-login.md"' )
    output = add_line(output, '     },')
    output = add_line(output, '     {')
    output = add_line(output, '         "title": "Add Workshop Utilities",' )
    output = add_line(output, '         "filename": "' + relpath_blocks + '/setup/add-workshop-utilities.md"' )
    output = add_line(output, '     },')

    for t in blocks:
        # how can we visually differentiate between blocks for different services?
        #t.cloud_service is the current_cloud_service:
        output = add_line(output, '     {')
        output = add_line(output, '         "title": "[' + t.cloud_service + "] " + t.name + '",' )
        output = add_line(output, '         "type": "freetier",' )
        output = add_line(output, '         "filename": "' + t.path + '"' )
        output = add_line(output, '     },')

    output = output[:len(output)-1]    
    output = add_line(output, '  ]')
    output = add_line(output, '}')
    print(output)
    try:
        filename = path_root + "/workshop/freetier/manifest.json"    
        h_manifest = open(filename, "w")
        h_manifest.write(output)
        h_manifest.close
    except Exception as e:
        print (type(e))
        print (str(e))

###########
# write the markdown file for the table of contents
###########
def write_toc():

    output = None
    output = add_line(output, "# List of Building Blocks and Tasks")
    output = add_line(output, "## Introduction")
    output = add_line(output, "")
    output = add_line(output, "Review the list of Building Blocks and Tasks that are currently available. Become a contributor by creating reusable components!")
    output = add_line(output, "## List of Building Blocks")
    output = add_line(output, "")
    output = add_line(output, "Building Blocks are exposed to customers. You can use these same blocks in your own workshop by adding the block to your manifest.json file.")
    output = add_line(output, "| Cloud Service | Block |  File | Description |")
    output = add_line(output, "|---------------| ---- |  ---- |------------ |")

    # Add the workshop utilities (hard code)
    output = add_line(output, '| setup | [Add Workshop Utilities](' + relpath_blocks + '/workshop/freetier/index.html?lab=add-workshop-utilities) |  ' + relpath_blocks + ' /setup/add-workshop-utilities.md| Utilities for adding data sets and users |')
    
    for t in blocks:
        this_name = t.md_name if not t.name else t.name
        #this_anchor = relpath_blocks + '/workshop/freetier/index.html?lab=' + t.cloud_service + '#' + re.sub('[^0-9a-zA-Z]+','', this_name)
        this_anchor = relpath_blocks + '/workshop/freetier/index.html?lab=' + t.md_name
        this_anchor = "[" + this_name + "](" + this_anchor + ")"
        this_description = t.description if t.description else " "
        output = add_line(output, "| " + t.cloud_service + " | " + this_anchor + " | " + t.path + " | " + this_description + " |")

    output = add_line(output, "")
    output = add_line(output, "[Go here for the customer view of Building Blocks](/building-blocks/workshop/freetier/index.html)")
    output = add_line(output, "## List of Tasks")
    output = add_line(output, "")
    output = add_line(output, "Listed below are the tasks that you can incorporate into your markdown. You can also use the navigation tree on the left to view the tasks. Again, contribute to the list of tasks!")
    output = add_line(output, "| Cloud Service | Task |  File | Description |")
    output = add_line(output, "|---------------| ---- |  ---- |------------ |")


    for t in tasks:
        this_name = t.md_name if not t.name else t.name
        this_anchor = relpath_blocks + '/how-to-author-with-blocks/workshop/index.html?lab=' + t.cloud_service + '#' + re.sub('[^0-9a-zA-Z]+','', this_name)
        this_anchor = "[" + this_name + "](" + this_anchor + ")"
        this_description = t.description if t.description else " "
        output = add_line(output, "| " + t.cloud_service + " | " + this_anchor + " | " + t.path + " | " + this_description + " |")

    output = add_line(output, "")
    output = add_line(output, "## Variable Defaults")
    output = add_line(output, "You can use the default variables or copy the default file to your project and override the settings. See the **Authoring using Blocks and Tasks** topic for details.")
    output = add_line(output, "")
    output = add_line(output, '[View default variable values](' + relpath_blocks + '/variables/variables.json)')
    output = add_line(output, "")


    output = add_line(output, "")
    output = add_line(output, "## manifest.json Template")
    output = add_line(output, "The manifest.json template below includes all the tasks that are currently available. You can remove those that you do not plan to use - either directly or thru a Block")
    output = add_line(output, "")
    output = add_line(output, "The template assumes you copied the default **variables.json** to the same directory as the **manifest.json** file.")    
    output = add_line(output, "")
    output = add_line(output, "```")
    output = add_line(output, "<copy>")
    output = add_line(output, get_manifest_template())
    output = add_line(output, "</copy>")
    output = add_line(output, "```")

    h_mdfile = None
    h_mdfile = open(path_howto + "/all-blocks-tasks.md", "w")
    h_mdfile.write(output)
    h_mdfile.close

    print(output)

###########
# write the markdown files for each cloud service tasks
###########
def write_cloud_service_tasks():

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
            h_mdfile = open(path_howto + "/" + t.cloud_service + ".md", "w")       
            current_cloud_service = t.cloud_service
            
            output = add_line(output, '# Tasks for OCI Service: ' + t.cloud_service.upper())

        this_name = t.md_name if not t.name else t.name
        output = add_line(output, '## ' + this_name)
        output = add_line(output, '**Markdown file location:**')
        output = add_line(output, "```")
        output = add_line(output, t.path)
        output = add_line(output, "```")
        output = add_line(output, "")
        output = add_line(output, '**Add to your manifest.json:**')
        output = add_line(output, "```")
        output = add_line(output, '"include": {')
        output = add_line(output, '     "' + t.include_name + '":"' + t.path)
        output = add_line(output, '}')
        output = add_line(output, "```")
        output = add_line(output, "")
        output = add_line(output, "**Add to your workshop markdown:**")
        output = add_line(output, "```")
        output = add_line(output, "[]&lpar;include:" + t.include_name + ")")
        output = add_line(output, "```")
        output = add_line(output, "")
        output = add_line(output, '**Markdown Output &#8595;&#8595;:**')
        output = add_line(output, " ")
        # [](include:adb-goto-sql-worksheet.md)
        output = add_line(output, "[](include:" + t.include_name + ")")
        output = add_line(output, " ")

    h_mdfile.write(output)
    h_mdfile.close()    

def main():
    load_labs("tasks")    
    load_labs("blocks") 
    write_task_manifest()
    write_toc()
    write_cloud_service_tasks()     
    write_blocks_manifest()


if __name__ == "__main__":
    main()
