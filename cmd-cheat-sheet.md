## Working in the shell

* `Ctrl+L` ~ clean cmd
* `Ctrl+Z` ~ kill/exit previous command
* `cd ..` ~ Go up a level
* `cd <path>` ~ set directory to given path
* `pwd` ~ path to directory
* `mkdir <new_dir>` ~ create a new dir
* `which python3` ~ python location
* `python3` ~ python version info

<br>
<hr>

## Working with github

#### Cloning from a specific branch
`git clone -b <branch-to-clone> <ssh-key> clone-name`

Or in a working example:
`git clone -b write_df_to_s3_fix git@github.com:moj-analytical-services/s3tools.git alt-ringfence`
<br><br>
#### Branches
`git push origin --delete {the_remote_branch} # Delete branch locally + remotely`
git checkout
<br><br>
#### Syncing up repos (specifically to allow creation of a test repo for an app)
https://www.opentechguides.com/how-to/article/git/177/git-sync-repos.html

Working example of the above:

To get everything setup, initially ensure you cd into your home directory. You can do this by using `cd ..`. If you go too far up the folder branches, you can path back down using `cd my_folder_i_want_to_access`.

If done correctly, your cmd session should end up looking like this: <br>
![Screenshot 2021-08-09 at 14 49 34](https://user-images.githubusercontent.com/45356472/128717070-4cba4063-1e12-488e-aaf0-bde7629220e9.png)

From there, enter the following code into terminal, line by line:
```
git clone --mirror git@github.com:moj-analytical-services/criminal-scenario-tool.git
cd criminal-scenario-tool.git
git remote add --mirror=fetch secondary git@github.com:moj-analytical-services/criminal-scenario-tool-testing.git
git fetch origin
git push secondary --all
```
Once done, ensure your directory stays within `criminal-scenario-tool-testing.git` (or equivalent).

Any updates from the master repo can subsequently be captured running the following lines:
```
git fetch origin
git push secondary --all
```

Please note, any changes to your secondary repo will lead to errors when attempting to run the above lines.
<br><br>
#### Resetting to a previous commit
More here - https://stackoverflow.com/questions/4114095/how-do-i-revert-a-git-repository-to-a-previous-commit

**Start by resetting to your previous commit**
`git reset --hard <commitId> && git clean -f
**Then update the github version**
```
git push origin/master --force
# or
# git push --force
```

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
`du -h /home/th368moj | grep '^\s*[0-9\.]\+G'` - to see disk usage. Change the G to an M to search for items in the MB

## Working in python
`pip list` - list all active packages in project
`git ls-files` - list files in git project
`python3 <script>` - run python script

##### Package Mangement

### Working with pip

**check to see if you have the latest version of pip**
`pip3 list`

**upgrade pip**
`pip3 install --upgrade pip —user`

**delete all packages**
`pip3 freeze | xargs pip3 uninstall -y`

**uninstall**
`pip install -U spacy`

<br>

### Virtual Environments

Venv online guide - https://docs.python.org/3/tutorial/venv.html

#### Personal Notes
##### Macbook
Create an environment by cd'ing to your desired location and then using:
`python3 -m virtualenv venv`

**activation of venv** (on mac)
source venv/bin/activate

**To activate your new env (at least inside VS)!**
Ctrl+Shift+P > Python Interpreter > Select your venv # still not working for me…

**to deactivate**
deactivate

##### Windows
`python -m venv venv`

CMD: <br><br>
![image](https://user-images.githubusercontent.com/44782232/134423260-4e992134-b8b8-47f1-8711-a53b16700a69.png)

For Powershell, use:
`venv\Scripts\Activate.ps1`

Install away...

One solution is to create a requirements.txt file. For example:
```
scrapy==2.4.1
APScheduler==3.7.0
itemloaders==1.0.4
w3lib==1.22.0
```
You can get your current package list through `pip freeze`
Then run `pip install -r requirements.txt` from the terminal
