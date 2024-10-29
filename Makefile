stop:
	./scripts/stop-all-services.sh 

start:
	./scripts/start-all-services.sh ./images

img:
	./scripts/build-apptainer-images.sh ./images ./images

