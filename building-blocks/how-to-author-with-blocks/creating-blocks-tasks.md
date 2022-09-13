# Creating Blocks and Tasks
## Introduction
**Everyone should contribute to Blocks and Tasks!** If you are creating a workshop and you have labs or tasks that you think will be useful to others - share them! It's easy - here's how.

## Create your lab's markdown
Create your workshop as you normally would. Try to keep content generic enough so that it can be used in multiple contexts. And, it may mean using variables instead of hardcoding names. 

### Create a block or task?
The block is equivalent to a lab. It may be difficult not to provide workshop specific information - especially in the introduction. If you can keep the content generic, then create a block!

Very frequently, a lab has tasks that are very generic. For example, Navigating to the object storage service is the same. So, make that a task and use variables to specify the compartment and bucket. Now, any lab that needs to navigate to the object store can simply include the task in their markdown. It's a one liner! And, when the UX changes, one update to the task will update all the workshops that use the task.

Don't forget to use tasks when creating your block :).

## Add a comment block to your markdown
The one addition you'll need to make to your markdown is a comment block. This comment block provides a title and description for your block or task. The documentation's master list of blocks and tasks is derived from these comment blocks.

Example block:
```
&lt;!--
    {
        "name":"Connect with SQL Worksheet",
        "description":"Connect to Autonomous Database using the SQL Worksheet in Database Actions"
    }
-->
# Connect with SQL Worksheet

## Introduction

In this lab, you will connect to Autonomous Database using the SQL Worksheet and explore its capabilities.

Estimated Time: 5 minutes
```

## Save your markdown to the building-blocks workshop
Save your markdown to the **building-blocks** workshop in the **oracle-livelabs/adb** repo. Each cloud service has its own folder in either the blocks or tasks parent folder. If your cloud service's folder doesn't exist yet, then simply add a new folder.

```
adb
.. building-blocks
.... blocks
........adb
........oac
.... tasks
........adb
........iam

```

## Regenerate the documentation
After creating new blocks and tasks, regenerate the documentation by running the **generate-documentation.py** python script found in the `/adb/building-blocks/scripts` folder. This script generates much of the how-to-author-with-blocks documentation.