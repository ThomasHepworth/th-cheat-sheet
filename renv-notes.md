### Initialising Project
To initialise a renv project, simply enter:
```
if(!"renv" %in% installed.packages()[, "Package"]) install.packages("renv") # install renv if it doesn't exist on your system
renv::init(bare = TRUE)
```
into the R console and your project will be created using renv. From here, install your required package list using the instructions below.

### Installing Required Packages

For this project, we're using renv to manage packages. An introduction to renv can be found [here](https://rstudio.github.io/renv/articles/renv.html). To install the packages needed for this project, simply run the following in a console window `renv::restore()`. If new packages are added by another user, `renv::restore()` will simply install your missing packages.

_Note:_ if you need to reclone the project at any point, you'll need to reinstall **all** packages. Renv works the same as virtual envs in python and simply installs the required packages in your given project.

### Installing and updating the package list

Install pacakages can be done using either `install.packages("package_name")` or `renv::install("package_name")`. To install a specific package version, you simply need to use `renv::install("package_name@0.0.1")`. Feel free to try it on `renv::install('ggplot2@3.0.0')`.

To install remotely, you simply need to enter the github suffix/project location. As an example, here's a package we're installing remotely in order to get the live version which isn't available on CRAN `renv::install('RinteRface/bs4Dash)'`. Again, feel free to run this if you'd like to test it out.

To update the package list, simply enter `renv::snapshot()`. This will open a prompt which will ask if you want to proceed (simply type **y**). Updates are added to `renv.lock`. If you wish to remove packages, simply delete them from here.

_Please only add packages we need for the project._

For further info, please see both:
* [The platform guidance for renv](https://user-guidance.services.alpha.mojanalytics.xyz/tools/package-management.html#renv)
* [The official introduction to renv](https://rstudio.github.io/renv/articles/renv.html)
