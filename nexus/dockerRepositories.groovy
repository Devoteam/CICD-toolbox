import org.sonatype.nexus.blobstore.api.BlobStoreManager

// create hosted repo and expose via https to allow deployments
repository.createDockerHosted('secure-dockerhub-mirror', null, 62283)

// create hosted repo and expose via http to allow deployments
repository.createDockerHosted('insecure-dockerhub-mirror', 8283,null)

// create proxy repo of Docker Hub and enable v1 to get search to work
// no ports since access is only indirectly via group
repository.createDockerProxy('netcicd-docker-proxy',                   // name
                             'https://registry-1.docker.io', // remoteUrl
                             'HUB',                          // indexType
                             null,                           // indexUrl
                             null,                           // httpPort
                             null,                           // httpsPort
                             BlobStoreManager.DEFAULT_BLOBSTORE_NAME, // blobStoreName 
                             true, // strictContentTypeValidation
                             true  // v1Enabled
                             )

 // create group and allow access via https
 def groupMembers = ['secure-dockerhub-mirror', 'netcicd-docker-proxy']
 repository.createDockerGroup('netcicd-docker-group', null, 63585, groupMembers, true)

log.info('Created Dockerhub mirror repository successfully')