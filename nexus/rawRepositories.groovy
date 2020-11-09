// create a new blob store dedicated to usage with raw repositories
def rawStore = blobStore.createFileBlobStore('raw', 'raw')

// and create a first raw hosted repository for documentation using the new blob store
repository.createRawHosted('NetCICD Test reports', rawStore.name)

log.info('Created repository for ROBOT testreports successfully')