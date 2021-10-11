# To run our docker image

For a full set of notes on deploying locally, see [here](https://user-guidance.services.alpha.mojanalytics.xyz/rshiny-app.html#deploying-locally)

For this project's files:
1) Copy the objects inside the docker folder (these should be stored in a project locally)
2) Open up your local cmd and cd into your project folder
3) Build your docker image using `docker build . -t {tag_name}:{tag_version}`, or `docker build . -t testing-docker-r-image:v0.0.4`
4) Once built, run your image and check it's working. This can be done either by using:
`docker run {tag_name}:{tag_version}`  or `docker run testing-docker-r-image:v0.0.4` 
![Screenshot 2021-10-11 at 15 49 18](https://user-images.githubusercontent.com/45356472/136810800-40723f66-81f7-4a71-a02b-aab130b29b85.png)
5) The version of RStudio that's been installed should be printed
6) You can see your created images through `docker image ls`. If you have your objects saved in containers, these can be accessed through `docker container ls`


To delete all of images (again, you can see your image list in docker or through `docker image ls`):
`Docker system prune --all`

_Note:_ You will have to reinstall cached items again (i.e. any base images you've downloaded in the GBs will need to be redownloaded).
