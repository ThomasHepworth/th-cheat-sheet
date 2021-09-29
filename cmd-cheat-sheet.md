## Working in the shell

* `Ctrl+L` ~ clean cmd
* `Ctrl+Z` ~ kill/exit previous command
* `cd ..` ~ Go up a level
* `cd <path>` ~ set directory to given path
* `pwd` ~ path to directory
* `mkdir <new_dir>` ~ create a new dir
* `which python3` ~ python location
* `python3` ~ python version info

### Git Commands

* `git remote show origin` - check which repo you are pointing at
* `git add <filename>` - add a file to your commit - https://git-scm.com/docs/git-add
* `git log --name-status` - see last commit items
* `git commit -m <commit_message>` - stage commit
* `git push` - push commit

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

### Jupyter lab

Initially, create a folder to store all of your data, scripts and venv in. 

You can do this in RStudio using the `New folder` button (see below image), or from either R or jupyter using the terminal. If using the terminal, simply enter `mkdir <folder_name>` (remove the `<` `>`). _Please ensure you are in your home directory when using the terminal command. Your terminal should look similar to the following image - ![Screenshot 2021-09-23 at 15 50 42](https://user-images.githubusercontent.com/45356472/134530301-b4fdf289-9f51-4480-9226-aa968191ee95.png)
_
<br><br>
![Screenshot 2021-09-23 at 15 48 30](https://user-images.githubusercontent.com/45356472/134529885-2cba8e85-4a13-45ab-97e8-94451847a3b8.png)

From here, enter the terminal in jupyter lab (File > New Launcher > Terminal). Again, make sure you are in your home directory to begin with (in English, you shouldn't be in a folder). For safety, just enter `cd` at this stage and you should be fine.

If this is your first time creating a venv, run the following two lines:
```
pip install ipykernel
pip install --upgrade pip
```

Then, in the terminal, enter (the ipykernel step is only necessary the first time you create a venv, so feel free to skip that line):
```
python3 -m venv venv
source venv/bin/activate
```

If done correctly, your terminal should look like so (see `(venv)` on the far left):
![Screenshot 2021-09-23 at 15 55 26](https://user-images.githubusercontent.com/45356472/134531111-7f0270bf-7857-4c35-b1fc-f7c855a46753.png)

Next, install your required packages - `pip install <package>`. For example, to install pandas, type `pip install pandas`

Once you have your packages installed, run the final step (replacing `<name_of_venv>`), which creates a new virtual environment to launch notebooks with:
`python -m ipykernel install --user -–name=<name_of_venv>`

And that's it. If done correctly, you should now have a new virtual environment that looks like so (your name will differ):
![Screenshot 2021-09-23 at 15 59 09](https://user-images.githubusercontent.com/45356472/134531826-fa7a2fac-3088-4b9f-bed2-16bc6b80b163.png)


### Personal Notes
#### Macbook
Create an environment by cd'ing to your desired location and then using:
`python3 -m virtualenv venv`

**activation of venv** (on mac)
source venv/bin/activate

**To activate your new env (at least inside VS)!**
Ctrl+Shift+P > Python Interpreter > Select your venv # still not working for me…

**to deactivate**
deactivate

#### Windows
`python -m venv venv`

CMD: <br><br>
![image](https://user-images.githubusercontent.com/44782232/134423260-4e992134-b8b8-47f1-8711-a53b16700a69.png)

For Powershell, use:
`venv\Scripts\Activate.ps1`

Install away...


### To save your package list for another to install

One solution is to create a requirements.txt file. For example:
```
scrapy==2.4.1
APScheduler==3.7.0
itemloaders==1.0.4
w3lib==1.22.0
```
You can get your current package list and save this to a file through `pip freeze > requirements.txt`
Then run `pip install -r requirements.txt` from the terminal
