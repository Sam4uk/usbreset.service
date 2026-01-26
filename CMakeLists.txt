cmake_minimum_required(VERSION 3.11)

execute_process(
    COMMAND date +%s
    OUTPUT_VARIABLE DATE_TWEAK
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

project(usbresetservice
    VERSION 0.1.6.${DATE_TWEAK}
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


file(WRITE "${PROJECT_FILE}.service"
"[Unit]\n"
"Description=Force reconnect USB Ethernet\n"
"After=multi-user.target\n\n"

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

file(WRITE "${PROJECT_FILE}.sh"
"#!/bin/bash\n\n"

# Список пристроїв для перезавантаження (VendorID ProductID Опис)
"DEVICES=(\n"
"    \"0bda 8152 'Realtek_Semiconductor_Corp._RTL8152_Fast_Ethernet_Adapter'\"\n"
"    \"0bda 8153 'Realtek_Semiconductor_Corp._RTL8152_Fast_Ethernet_Adapter'\"\n"
# "    \"0483 5740 'STM32_Device'\"\n"
# "    \"1d6b 0002 USB_Hub\"\n"
")\n\n"

"echo \"=== USB Device Reset Utility ===\"\n"
"echo \"Кількість пристроїв для перезавантаження: \$\{#DEVICES[@]\}\"\n"
"echo \"\"\n\n"

# Очікування перед початком
"sleep 15\n\n"

" for DEVICE_ENTRY in \"\$\{DEVICES[@]\}\"; do\n"
"     # Розбираємо запис пристрою\n"
"     VENDOR_ID=$(echo \"$DEVICE_ENTRY\" | awk '{print $1}')\n"
"     PRODUCT_ID=$(echo \"$DEVICE_ENTRY\" | awk '{print $2}')\n"
"     DEVICE_DESC=$(echo \"$DEVICE_ENTRY\" | awk '{$1=$2=\"\"; print $0}' | xargs)\n"
"\n"
"     echo \"----------------------------------------\"\n"
"     echo \"Пристрій: \$\{DEVICE_DESC:-Без опису\}\"\n"
"     echo \"VendorID: $VENDOR_ID, ProductID: $PRODUCT_ID\"\n"
"\n"
    # Перезавантаження пристрою
"     if sudo udevadm trigger --action=change \\\n"
"         --subsystem-match=usb \\\n"
"         --attr-match=\"idVendor=$VENDOR_ID\" \\\n"
"         --attr-match=\"idProduct=$PRODUCT_ID\" 2>/dev/null; then\n"
"         echo \"Статус: Успішно перезавантажено\"\n"
"     else\n"
"         echo \"Статус: Помилка при перезавантаженні\"\n"
"     fi\n"
"\n"
    # Затримка між операціями
"     sleep 2\n"
"done\n"

"echo \"----------------------------------------\"\n"
"echo \"Процес перезавантаження завершено!\"\n"
"echo \"Остаточне очікування...\"\n"
"sleep 4\n"
"# Для Raspberry Pi 4 (скидає живлення на всіх USB портах одразу)\n"
"sudo uhubctl -l 2 -a cycle\n"

)

install(
    PROGRAMS "${PROJECT_FILE}.sh" 
    DESTINATION /usr/local/bin)

# file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG}.sh" "")
# file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG}.sh"
# "DEVICE_LIST=\(\n\t\"2c7c 0125\"\n\)"
# )

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/postinst"
"#!/bin/sh\n\n"
"sudo systemctl daemon-reload\n"
"sudo systemctl enable usbresetservice.service\n"
"sudo systemctl start usbresetservice.service\n"
)

# Надати права на виконання
file(CHMOD "${CMAKE_CURRENT_BINARY_DIR}/postinst" 
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE 
    GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# file(CHMOD "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG}.sh" 
#     PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE 
#     GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

file(CHMOD "${PROJECT_FILE}.sh" 
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE 
    GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

# install(
#     PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG}.sh" 
#     DESTINATION /usr/local/etc/)

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
