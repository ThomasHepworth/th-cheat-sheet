## Working in the shell

* `Ctrl+L` ~ clean cmd
* `Ctrl+Z` ~ kill/exit previous command
* `cd ..` ~ Go up a level
* `cd <path>` ~ set directory to given path

<br>
<hr>

## Working with github

#### Cloning from a specific branch
`git clone -b <branch-to-clone> <ssh-key> clone-name`

Or in a working example:
`git clone -b write_df_to_s3_fix git@github.com:moj-analytical-services/s3tools.git alt-ringfence`

#### Branches
`git push origin --delete {the_remote_branch} # Delete branch locally + remotely`
git checkout

#### Syncing up repos (specifically to allow creation of a test repo for an app)
https://www.proofhub.com/articles/effective-communication

Working example of the above:

To get everything setup, initially ensure you cd into your home directory. From there, follow the instructions below:
```
git clone --mirror git@github.com:moj-analytical-services/criminal-scenario-tool.git
cd criminal-scenario-tool.git
git remote add --mirror=fetch secondary git@github.com:moj-analytical-services/criminal-scenario-tool-testing.git
git fetch origin
git push secondary --all
git@github.com:moj-analytical-services/criminal-scenario-tool-testing.git
```
Once done, ensure your directory stays within `criminal-scenario-tool-testing.git` (or equivalent).

Any updates from the master repo can subsequently be captured running the following lines:
```
git fetch origin
git push secondary --all
```

Please note, any changes to your secondary repo will lead to errors when attempting to run the above lines.

<br>
<hr>

## Working in R/python

#### Working with branches in the shell
**Purported to resolve git index errors on the platform**

##### Creating
`git checkout -b <new_name>` - create a new branch
`git checkout -m <branch_name>` - checkout

##### Deleting
delete branches remotely and locally - https://www.freecodecamp.org/news/how-to-delete-a-git-branch-both-locally-and-remotely/

**delete branch locally**
`git branch -d localBranchName`

**delete branch remotely**
`git push origin --delete remoteBranchName`

**sync up branch list through**
`git fetch -p`

#### Search/replace strings
`git grep -n "my regular expression search string"`

#### Disk Usage
`Du -h /home/th368moj | grep '^\s*[0-9\.]\+G'` - to see disk usage. Change the G to an M to search for items in the MB

## Working in python
`pip list` - list all active packages in project
`git ls-files` - list files in git project
`python3 <script>` - run python script

##### Package Mangement
**Update with notes on virtual envs at a later date**

One solution is to create a requirements.txt file. For example:
```
scrapy==2.4.1
APScheduler==3.7.0
itemloaders==1.0.4
w3lib==1.22.0
```

Then run `pip install -r requirements.txt` from the terminal
