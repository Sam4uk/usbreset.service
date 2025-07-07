project_name := usbresetservice
project_version := 0.1.2
project_arch := all


source := usb_reset_service

project :=  ${project_name}_${project_version}_${project_arch}

files :=${source}/DEBIAN/postinst ${source}/etc/systemd/system/usb_reset_service.service Makefile

all: ${project}.deb #${project}.zip 

${source}/DEBIAN/control: $(files)
	echo "Оновлення control file"
	@echo "Version: ${project_version}.$$(date +%s)" > ${source}/DEBIAN/control
	@echo "Architecture: ${project_arch}" >> ${source}/DEBIAN/control
	@echo "Package: ${project_name}" >> ${source}/DEBIAN/control
	@echo "Section: custom" >> ${source}/DEBIAN/control
	@echo "Maintainer: sam4uk.github.io" >> ${source}/DEBIAN/control
	@echo "Description: sam4uk.github.io" >> ${source}/DEBIAN/control
	@echo "Depends: vim" >> ${source}/DEBIAN/control

# ${project}.zip: $(files)
# 	echo "Оновлення zip"
# 	@cp ${source}/usr/local/bin/oculos.py ${source}/../
# 	@zip -m9ry "${project_name}_${project_version}.zip" oculos.py

${project}.deb: $(files) ${source}/DEBIAN/control
	echo "Оновлення deb"
	@ dpkg-deb --root-owner-group --build ${source} ${project_name}_${project_version}_${project_arch}.deb
	@rm ${source}/DEBIAN/control

install:
	cp ${project}.deb /tmp
	sudo apt install -y /tmp/${project}.deb  

clean:
	@rm -f ${project_name}_${project_version}_${project_arch}.deb
