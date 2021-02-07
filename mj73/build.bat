"C:\Program Files (x86)\PICO-8\pico8.exe" mj73.p8 -export "build/web/index.html"
"C:\Program Files (x86)\PICO-8\pico8.exe" mj73.p8 -export "build/chargin_chuck.bin"

butler push build/web mrhthepie/chargin-chuck:web
butler push build/chargin_chuck.bin/windows mrhthepie/chargin-chuck:windows
butler push build/cart mrhthepie/chargin-chuck:cart
