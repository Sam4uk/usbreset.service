cmake_minimum_required(VERSION 3.11)

execute_process(
    COMMAND date +%s
    OUTPUT_VARIABLE DATE_TWEAK
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

project(usbresetservice
    VERSION 0.1.4.${DATE_TWEAK}
    DESCRIPTION "usbresetservice"
    HOMEPAGE_URL "sam4uk.github.io")

set(SLEEP 6)

set(PROJECT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")

file(WRITE ${PROJECT_BINARY_DIR}/.gitignore
    [=====[
# CMAKE generated file: DO NOT EDIT!
*
*.*
]=====]
)


file(WRITE "${PROJECT_FILE}.service" "")
file(APPEND "${PROJECT_FILE}.service"
"[Unit]\n"
"Description=Force reconnect USB Ethernet\n"
"After=network.target\n\n"

"[Service]\n"
"Type=oneshot\n"
"ExecStart=/usr/local/bin/${PROJECT_NAME}.sh\n"
"RemainAfterExit=true\n\n"

"[Install]\n"
"WantedBy=multi-user.target\n"
)

install(
    PROGRAMS "${PROJECT_FILE}.service" 
    DESTINATION /etc/systemd/system/)

set(PROJECT_CONFIG "usb_reset_config")

file(WRITE "${PROJECT_FILE}.sh" "")
file(APPEND "${PROJECT_FILE}.sh"
"#!/bin/sh\n"
"source /usr/local/etc/${PROJECT_CONFIG}.sh\n"
"echo \"USB reload usbreset\"\n"
"sleep ${SLEEP}\n\n"

"for DEVICE in \"\${DEVICE_LIST[@]}\"; do\n\t"
    "echo \"usbreset \${DEVICE}\"\n\t"

    "sudo udevadm trigger --action=change --subsystem-match=usb "
    "--attr-match \\\n\tidVendor=\$(echo \"\$DEVICE\" | awk '{print \$1}') "
    "--attr-match \\\n\tidProduct=\$(echo \"\$DEVICE\" | awk '{print \$2}')\n\t"

    "sleep ${SLEEP}\ndone\n"
)

install(
    PROGRAMS "${PROJECT_FILE}.sh" 
    DESTINATION /usr/local/bin)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG}.sh" "")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG}.sh"
"DEVICE_LIST=\(\n\t\"2c7c 0125\"\n\)"
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/postinst" "")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/postinst"
"#!/bin/sh\n\n"
"sudo systemctl daemon-reload\n"
"sudo systemctl enable usbresetservice.service\n"
"sudo systemctl start usbresetservice.service\n"
)

# Надати права на виконання
file(CHMOD "${CMAKE_CURRENT_BINARY_DIR}/postinst" 
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE 
    GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

install(
    PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG}.sh" 
    DESTINATION /usr/local/etc/)

set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_CURRENT_BINARY_DIR}/postinst"
)


set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "sam4uk")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "sam4uk")
set(CPACK_PACKAGE_CONTACT "Sam4uk")# or CPACK_DEBIAN_PACKAGE_MAINTAINER)
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.28)")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}.${DATE_TWEAK}")

set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")

set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
# set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_SOURCE_DIR}/decription)
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
set(CPACK_PACKAGE_HOMEPAGE_URL ${PROJECT_HOMEPAGE_URL})

message("${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA}")



include(CPack)