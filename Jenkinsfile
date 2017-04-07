/**
 * Docker Aptly image build pipeline
 *
 * IMAGE_GIT_URL - Image git repo URL
 * IMAGE_BRANCH - Image repo branch
 * IMAGE_CREDENTIALS_ID - Image repo credentials id
 * IMAGE_TAGS - Image tags
 * REGISTRY_URL - Docker registry URL (can be empty)
 * REGISTRY_CREDENTIALS_ID - Docker hub credentials id
 *
**/

def common = new com.mirantis.mk.Common()
def gerrit = new com.mirantis.mk.Gerrit()
def dockerLib = new com.mirantis.mk.Docker()
node("docker") {
  def workspace = common.getWorkspace()
  def imageTagsList = IMAGE_TAGS.tokenize(" ")
  try{
    def aptly, aptlyApi, aptlyPublisher, aptlyPublic
    docker.withRegistry(REGISTRY_URL, REGISTRY_CREDENTIALS_ID) {
      stage("checkout") {
         gerrit.gerritPatchsetCheckout(IMAGE_GIT_URL, "", IMAGE_BRANCH, IMAGE_CREDENTIALS_ID)
      }
      stage("build") {
        common.infoMsg("Building aptly")
        aptly = dockerLib.buildDockerImage("tcpcloud/aptly", "", "docker/aptly.Dockerfile", imageTagsList[0])
        if(!aptly){
          throw new Exception("Docker aptly build image failed")
        }

        common.infoMsg("Building aptly-api ")
        aptlyApi = dockerLib.buildDockerImage("tcpcloud/aptly-api", "", "docker/aptly-api.Dockerfile", imageTagsList[0])
        if(!aptlyApi){
          throw new Exception("Docker aptly-api build image failed")
        }

        common.infoMsg("Building aptly-publisher")
        aptlyPublisher = dockerLib.buildDockerImage("tcpcloud/aptly-publisher", "", "docker/aptly-publisher.Dockerfile", imageTagsList[0])
        if(!aptlyPublisher){
          throw new Exception("Docker aptly-publisher build image failed")
        }

        common.infoMsg("Building aptly-public")
        aptlyPublic = dockerLib.buildDockerImage("tcpcloud/aptly-public", "", "docker/aptly-public.Dockerfile", imageTagsList[0])
        if(!aptlyPublic){
          throw new Exception("Docker aptly-public build image failed")
        }
      }
      stage("upload to docker hub"){
        common.infoMsg("Uploading aptly image with tags ${imageTagsList}")
        for(int i=0;i<imageTagsList.size();i++){
          aptly.push(imageTagsList[i])
        }
        common.infoMsg("Uploading aptly-api image with tags ${imageTagsList}")
        for(int i=0;i<imageTagsList.size();i++){
          aptlyApi.push(imageTagsList[i])
        }
        common.infoMsg("Uploading aptly-publisher image with tags ${imageTagsList}")
        for(int i=0;i<imageTagsList.size();i++){
          aptlyPublisher.push(imageTagsList[i])
        }
        common.infoMsg("Uploading aptly-public image with tags ${imageTagsList}")
        for(int i=0;i<imageTagsList.size();i++){
          aptlyPublic.push(imageTagsList[i])
        }
      }
    }
  } catch (Throwable e) {
     // If there was an error or exception thrown, the build failed
     currentBuild.result = "FAILURE"
     throw e
  } finally {
     common.sendNotification(currentBuild.result,"",["slack"])
  }
}
